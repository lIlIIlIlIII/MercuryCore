import surql from "$lib/surrealtag"
import { query, squery } from "$lib/server/surreal"
import { error } from "@sveltejs/kit"
import fs from "fs"
import "dotenv/config"

type Render = {
	id: number
	type: "Clothing" | "Avatar"
	status: "Pending" | "Rendering" | "Completed" | "Error"
	created: string
	completed: string | null
	relativeId: number
}

export async function POST({ request, url }) {
	const apiKey = url.searchParams.get("apiKey")
	if (!apiKey || apiKey != process.env.RCC_KEY) throw error(400, "yeat")

	const id = url.searchParams.get("taskID")
	if (!id || !/^[\d\w]+$/.test(id))
		throw error(400, "Missing taskID parameter")

	const task = await squery<Render>(surql`SELECT * FROM $render`, {
		render: `render:${id}`,
	})

	if (!task) throw error(404, "Task not found")

	const json = await request.json(),
		status: number = json.Status

	if (status == 1) {
		await query(
			surql`UPDATE render SET status = "Rendering" WHERE taskID = $id`,
			{ id },
		)
	} else if (status == 2) {
		const base64: string = json.Click

		// Convert base64 from RCCService to an image
		const path = `data/${
			task.type == "Avatar" ? "avatars" : "thumbnails"
		}/${task.relativeId}.png`

		fs.writeFileSync(path, base64, "base64")

		await query(
			surql`
				UPDATE render MERGE {
					status: "Completed",
					completed: time::now(),
				} WHERE taskID = $id`,
			{ id },
		)
	}

	return new Response()
}
