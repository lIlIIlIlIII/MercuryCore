import { prisma } from "$lib/server/prisma"

export const load = async () => ({
	transactions: prisma.transaction.findMany({
		include: {
			sender: true,
			receiver: true,
		},
		orderBy: {
			time: "desc",
		},
	}),
})
