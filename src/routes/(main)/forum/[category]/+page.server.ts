import { authorise } from "$lib/server/lucia"
import surreal, { squery, surql } from "$lib/server/surreal"
import formData from "$lib/server/formData"
import { error } from "@sveltejs/kit"
import { likeActions } from "$lib/server/like"

export async function load({ locals, params }) {
	const { user } = await authorise(locals)
	const category = await squery<{
		description: string
		name: string
		posts: {
			author: {
				number: number
				status: "Playing" | "Online" | "Offline"
				username: string
			}
			content: {
				text?: string
			}[]
			dislikeCount: number
			dislikes: boolean
			id: string
			likeCount: number
			likes: boolean
			posted: string
			title: string
			visibility: string
		}[]
	}>(
		surql`
			SELECT
				*,
				(SELECT
					*,
					meta::id(id) AS id,
					(SELECT text, updated FROM $parent.content
					ORDER BY updated DESC) AS content,
					(SELECT
						number,
						status,
						username
					FROM <-posted<-user)[0] AS author,
					count(<-likes<-user) AS likeCount,
					count(<-dislikes<-user) AS dislikeCount,
					($user ∈ <-likes<-user.id) AS likes,
					($user ∈ <-dislikes<-user.id) AS dislikes
				FROM $parent<-in.in) AS posts
			OMIT id
			FROM forumCategory
			WHERE string::lowercase(name) = string::lowercase($category)`,
		{
			...params,
			user: `user:${user.id}`,
		},
	)

	if (!category) throw error(404, "Not found")

	return category
}

export const actions = {
	like: async ({ request, locals, url }) => {
		const { user } = await authorise(locals),
			data = await formData(request),
			action = data.action as keyof typeof likeActions,
			id = url.searchParams.get("id"),
			replyId = url.searchParams.get("rid")

		if (
			(id && !(await surreal.select(`forumPost:${id}`))[0]) ||
			(replyId && !(await surreal.select(`forumReply:${replyId}`))[0])
		)
			throw error(404)

		await likeActions[action](
			user.id,
			`forum${replyId ? "Reply" : "Post"}:${id || replyId}`,
		)
	},
}
