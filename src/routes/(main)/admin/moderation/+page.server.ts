import { authorise } from "$lib/server/lucia"
import ratelimit from "$lib/server/ratelimit"
import { prisma } from "$lib/server/prisma"
import type { ModerationActionType } from "@prisma/client"
import formError from "$lib/server/formError"
import { superValidate, message } from "sveltekit-superforms/server"
import { z } from "zod"

const schema = z.object({
	username: z.string().min(3).max(21),
	action: z.number().min(1).max(5),
	banDate: z.string().optional(),
	reason: z.string().min(15).max(150),
})

export async function load(event) {
	// Make sure a user is an administrator/moderator before loading the page.
	await authorise(event.locals, 4)

	return {
		form: superValidate(event, schema),
	}
}

export const actions = {
	moderateUser: async event => {
		const { user } = await authorise(event.locals, 4)

		const limit = ratelimit("moderateUser", event.getClientAddress, 30)
		if (limit) return limit

		const form = await superValidate(event, schema)
		if (!form.valid) return formError(form)

		const { username, action, banDate, reason } = form.data

		const date = banDate ? new Date(banDate) : null

		if (action == 2 && (date?.getTime() || 0) < new Date().getTime())
			return formError(form, ["banDate"], ["Invalid date"])

		const getModeratee = await prisma.authUser.findUnique({
			where: {
				username,
			},
		})

		if (!getModeratee)
			return formError(form, ["username"], ["User does not exist"])

		if (getModeratee.permissionLevel > 2)
			return formError(
				form,
				["username"],
				["You cannot moderate staff members"]
			)
		if (getModeratee.id == user.id)
			return formError(
				form,
				["username"],
				["You cannot moderate yourself"]
			)

		const moderationMessage = [
			"has been warned",
			`has been banned until ${date?.toLocaleDateString()}`,
			"has been terminated",
			"has been deleted",
			"has been unbanned",
		]

		const moderationActions = [
			"Warning",
			"Ban",
			"Termination",
			"AccountDeleted",
		]

		if (action == 5) {
			// Unban
			if (
				!(await prisma.moderationAction.count({
					where: { moderateeId: getModeratee.id, active: true },
				}))
			)
				return formError(
					form,
					["action"],
					["You cannot unban a user that has not been moderated yet"]
				)

			if (
				await prisma.moderationAction.count({
					where: {
						moderateeId: getModeratee.id,
						active: true,
						type: "AccountDeleted",
					},
				})
			)
				return formError(
					form,
					["action"],
					["You cannot unban a deleted user"]
				)

			await prisma.moderationAction.updateMany({
				where: {
					moderateeId: getModeratee.id,
				},
				data: {
					active: false,
				},
			})

			return {
				moderationsuccess: true,
				msg: `${username} ${moderationMessage[action - 1]}`,
			}
		}

		const moderationAction = moderationActions[action - 1]

		if (
			await prisma.moderationAction.count({
				where: { moderateeId: getModeratee.id, active: true },
			})
		)
			return formError(
				form,
				["username"],
				["User has already been moderated"]
			)

		await prisma.moderationAction.create({
			data: {
				moderator: {
					connect: {
						id: user.id,
					},
				},
				moderatee: {
					connect: {
						username,
					},
				},
				timeEnds: date || new Date(),
				note: reason,
				type: moderationAction as ModerationActionType,
			},
		})

		if (action == 4)
			// Delete Account
			await prisma.authUser.update({
				where: {
					username,
				},
				data: {
					username: `[ Deleted User ${getModeratee.number} ]`,
				},
			})

		return message(form, `${username} ${moderationMessage[action - 1]}`)
	},
}
