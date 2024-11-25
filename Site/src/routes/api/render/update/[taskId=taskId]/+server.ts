import { Record, db } from "$lib/server/surreal"
import { error } from "@sveltejs/kit"
import completeQuery from "./completeQuery.surql"
import renderQuery from "./renderQuery.surql"

type Render = {
	type: "Clothing" | "Avatar"
	relativeId: number
}

export async function POST({ request, url, params }) {
	const apiKey = url.searchParams.get("apiKey")
	if (!apiKey || apiKey !== process.env.RCC_KEY) error(403, "Stfu")

	const render = Record("render", params.taskId)
	const [[task]] = await db.query<Render[][]>(renderQuery, { render })
	if (!task) error(404, "Task not found")

	// More stuff is done with the proxy now, so we don't need to gunzip it
	const [status, clickBody, clickHead] = new TextDecoder()
		.decode(await request.arrayBuffer())
		.split("\n")

	const getPath = (name: string) =>
		task.type === "Avatar"
			? `../data/avatars/${task.relativeId}${name && "-"}${name}.png`
			: `../data/thumbnails/${task.relativeId}${name && "-"}${name}`
	const write = (input: string, name = "") =>
		Bun.write(getPath(name), Buffer.from(input, "base64").toString())

	console.log("Render status update:", status)
	if (status === "Rendering") await db.merge(render, { status: "Rendering" })
	else if (status === "Completed") {
		// todo make proxy return multipart/form-data or something for lower bandwidth than base64
		if (clickHead && clickBody)
			await Promise.all([
				write(clickHead, "head"),
				write(clickBody, "body"),
			])
		else if (clickBody) await write(clickBody)

		await db.query(completeQuery, { render })
	}
	return new Response()
}
