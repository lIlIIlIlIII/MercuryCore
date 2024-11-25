import exclude from "$lib/server/exclude"
import { authorise } from "$lib/server/lucia"
import { db } from "$lib/server/surreal"
import statisticsQuery from "./statistics.surql"

export async function load({ locals }) {
	exclude("Statistics")
	await authorise(locals)

	return { stats: await db.query<number[]>(statisticsQuery) }
}
