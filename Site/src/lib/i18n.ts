import { browser } from "$app/environment"
import { init, locale, register } from "svelte-i18n"

// todo: support server-side, flag emoji on the footer

// ref: http://www.lingoes.net/en/translator/langcode.htm
const defaultLocale = "en-US"
export const availableLocales = [
  { code: "en-US", label: "English (US)", flag: "🇺🇸" },
  { code: "es-ES", label: "Español", flag: "🇪🇸" }
]

availableLocales.forEach(({ code }) => {
  register(code, () => import(`../locales/${code}.json`))
})

init({
  fallbackLocale: defaultLocale,
  initialLocale: browser ? localStorage.getItem("locale") : defaultLocale,
});

export function setLocale(localeCode: string) {
  const localeSupported = availableLocales.some(loc => loc.code === localeCode)
  localeCode = localeSupported ? localeCode : defaultLocale

  localStorage.setItem("locale", localeCode)
  locale.set(localeCode)
}