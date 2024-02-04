import { Message } from '@/types/message.types'

const API_ENDPOINT = '/api/data'
export const getMessages = async () => {
	try {
		const response = await fetch(API_ENDPOINT)
		if (!response.ok) {
			throw new Error('Error fetching messages')
		}
		const { items } = await response.json()
		return items as Message[]
	} catch (e) {
		console.error(e)
		throw e
	}
}

export const deleteMessage = async (id: string) => {
	const response = await fetch(`${API_ENDPOINT}?id=${id}`, {
		method: 'DELETE',
	})
	if (!response.ok) {
		throw new Error('Failed to delete message')
	}
	return response.text()
}

export const postMessage = async (message: Omit<Message, 'id'>) => {
	const response = await fetch(API_ENDPOINT, {
		method: 'POST',
		headers: {
			'Content-Type': 'application/json',
		},
		body: JSON.stringify(message),
	})
	if (!response.ok) {
		throw new Error('Failed to send message')
	}
	return response.text()
}
