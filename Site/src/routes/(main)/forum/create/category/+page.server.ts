import exclude from "$lib/server/exclude"
import formError from "$lib/server/formError"
import { authorise } from "$lib/server/lucia"
import ratelimit from "$lib/server/ratelimit"
import { db } from "$lib/server/surreal"
import { redirect } from "@sveltejs/kit"
import { zod } from "sveltekit-superforms/adapters"
import { superValidate } from "sveltekit-superforms/server"
import { z } from "zod"
import createQuery from "./create.surql"

const schema = z.object({
	name: z.string().max(50),
	description: z.string().max(300),
})

export async function load({ locals }) {
	exclude("Forum")
	await authorise(locals, 5)
	return { form: await superValidate(zod(schema)) }
}

export const actions: import("./$types").Actions = {}
actions.default = async ({ request, locals, getClientAddress }) => {
	exclude("Forum")
	await authorise(locals, 5)
	const form = await superValidate(request, zod(schema))
	if (!form.valid) return formError(form)

	const { name, description } = form.data
	// Conflicts with /forum/create
	if (name.toLowerCase() === "create")
		return formError(form, ["name"], ["Can't park there mate"])

	const limit = ratelimit(form, "forumCategory", getClientAddress, 30)
	if (limit) return limit

	await db.query(createQuery, { name, description })

	redirect(302, `/forum/${name}`)
}
