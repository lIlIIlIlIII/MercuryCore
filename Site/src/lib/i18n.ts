import { browser } from "$app/environment"
import { init, locale, register } from "svelte-i18n"

// ref: http://www.lingoes.net/en/translator/langcode.htm
const defaultLocale = "en-US"
export const availableLocales = [
  { code: "en-US", label: "English (US)" },
  { code: "es-ES", label: "Español" }
]

availableLocales.forEach(({ code }) => {
  register(code, () => import(`../locales/${code}.json`))
})

init({
  fallbackLocale: defaultLocale,
  initialLocale: browser ? localStorage.getItem("locale") : defaultLocale, // TODO: default locale is displayed for a second when refreshing the page
});

export function setLocale(localeCode: string) {
  const localeSupported = availableLocales.some(loc => loc.code === localeCode)
  localeCode = localeSupported ? localeCode : defaultLocale

  localStorage.setItem("locale", localeCode)
  locale.set(localeCode)
}