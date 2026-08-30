import React, { createContext, useState, useContext, useEffect } from 'react';
import { translations } from '../utils/translations';

const LanguageContext = createContext();

export const LanguageProvider = ({ children }) => {
  const [language, setLanguage] = useState('en');

  useEffect(() => {
    // Instantly flip the entire app to Right-To-Left when Arabic is selected
    document.documentElement.dir = language === 'ar' ? 'rtl' : 'ltr';
    document.documentElement.lang = language;
    const needsPageLocalization = language === 'ar' || document.documentElement.dataset.pageLanguage === 'ar';
    if (!needsPageLocalization) return undefined;

    let disposed = false;
    let cleanup = () => {};

    import('../utils/pageTranslations').then(({ localizePage }) => {
      if (disposed) return;
      localizePage(document.body, language);
      document.documentElement.dataset.pageLanguage = language;

      const pendingNodes = new Set();
      let animationFrame = null;
      const scheduleLocalization = (node) => {
        pendingNodes.add(node);
        if (animationFrame !== null) return;
        animationFrame = requestAnimationFrame(() => {
          pendingNodes.forEach((pendingNode) => localizePage(pendingNode, language));
          pendingNodes.clear();
          animationFrame = null;
        });
      };

      const observer = new MutationObserver((mutations) => {
        mutations.forEach(({ addedNodes, target, type, attributeName }) => {
          if (type === 'characterData') scheduleLocalization(target);
          if (type === 'attributes' && (attributeName === 'placeholder' || attributeName === 'title' || attributeName === 'aria-label')) {
            scheduleLocalization(target);
          }
          addedNodes.forEach(scheduleLocalization);
        });
      });
      observer.observe(document.body, {
        childList: true,
        subtree: true,
        characterData: true,
        attributes: true,
        attributeFilter: ['placeholder', 'title', 'aria-label'],
      });

      cleanup = () => {
        observer.disconnect();
        if (animationFrame !== null) cancelAnimationFrame(animationFrame);
      };
    });

    return () => {
      disposed = true;
      cleanup();
    };
  }, [language]);

  const t = (key) => {
    return translations[language][key] || key;
  };

  const toggleLanguage = () => {
    setLanguage(prev => prev === 'en' ? 'ar' : 'en');
  };

  return (
    <LanguageContext.Provider value={{ language, toggleLanguage, t }}>
      {children}
    </LanguageContext.Provider>
  );
};

export const useLanguage = () => useContext(LanguageContext);
