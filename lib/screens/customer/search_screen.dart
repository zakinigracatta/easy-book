import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../models/business_model.dart';
import '../../providers/app_providers.dart';
import '../../theme/app_colors.dart';
import '../../widgets/customer_bottom_nav.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rating_stars.dart';

final customerSearchBusinessesProvider =
    FutureProvider.family<List<BusinessModel>, String>((ref, query) async {
  final repository = ref.watch(businessRepositoryProvider);
  return repository.fetchBusinesses(query: query.trim());
});

class SearchScreen extends ConsumerStatefulWidget {
  SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final next = _searchController.text.trim();
    if (next == _query) return;
    setState(() => _query = next);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();
    super.dispose();
  }

  Color _mutedColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : AppColors.textMutedLight;
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(customerSearchBusinessesProvider(_query));

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('Search & Explore'))),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: CustomTextField(
              controller: _searchController,
              label: context.tr('Search salons, spas or locations'),
              prefixIcon: Icons.search,
            ),
          ),
          Expanded(
            child: businessesAsync.when(
              loading: () => Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => _errorState(),
              data: (businesses) {
                if (businesses.isEmpty) return _emptyState();

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(customerSearchBusinessesProvider(_query));
                    await ref.read(
                      customerSearchBusinessesProvider(_query).future,
                    );
                  },
                  child: ListView.separated(
                    physics: AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 90),
                    itemCount: businesses.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _businessTile(context, businesses[index]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomerBottomNav(currentIndex: 1),
    );
  }

  Widget _businessTile(BuildContext context, BusinessModel business) {
    final imageUrl = business.imageUrl.trim();
    final mutedColor = _mutedColor(context);

    return GlassCard(
      onTap: () => context.push('/salon/${business.id}'),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: imageUrl.isEmpty
                ? _imagePlaceholder()
                : Image.network(
                    imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        business.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (business.isVerified)
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  business.address.isEmpty
                      ? business.category
                      : business.address,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: mutedColor),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    RatingStars(rating: business.rating),
                    SizedBox(width: 6),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${business.rating.toStringAsFixed(1)} (${business.reviewCount})',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      color: AppColors.primary.withValues(alpha: 0.08),
      child: Icon(
        Icons.storefront_rounded,
        color: AppColors.primary,
        size: 30,
      ),
    );
  }

  Widget _emptyState() {
    final title = _query.isEmpty
        ? context.tr('No businesses available yet')
        : context.tr('No results for “{query}”', params: {'query': _query});

    return ListView(
      physics: AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(24),
      children: [
        SizedBox(height: 100),
        Icon(Icons.search_off_rounded, size: 52),
        SizedBox(height: 14),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          context.tr('Try another search or check again later.'),
          textAlign: TextAlign.center,
          style: TextStyle(color: _mutedColor(context)),
        ),
      ],
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 48),
            SizedBox(height: 12),
            Text(
              context.tr('Could not load search results'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            TextButton.icon(
              onPressed: () =>
                  ref.invalidate(customerSearchBusinessesProvider(_query)),
              icon: Icon(Icons.refresh_rounded),
              label: Text(context.tr('Try Again')),
            ),
          ],
        ),
      ),
    );
  }
}
