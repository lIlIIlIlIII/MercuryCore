import "$lib/i18n"
import { waitLocale } from "svelte-i18n"

// TODO: to prevent issues we need to call waitLocale so each layout needs the exact same code
export const load = async () => {
	await waitLocale()
}