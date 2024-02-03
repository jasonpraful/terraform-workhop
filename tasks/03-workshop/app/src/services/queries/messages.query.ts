import { QueryClient, useMutation, useQuery } from '@tanstack/react-query'
import toast from 'react-hot-toast'

import type { Message } from '@/types/message.types'
// import APIs here

const getDummyResponses = (): Message[] | null => {
	const messages = window.localStorage.getItem('messages')
	if (!messages) {
		return []
	}
	return JSON.parse(messages) as Message[]
}

const updateDummyResponses = (message: Message): void => {
	const currentMessages = getDummyResponses()
	if (currentMessages) {
		window.localStorage.setItem(
			'messages',
			JSON.stringify([...currentMessages, message]),
		)
	} else {
		window.localStorage.setItem('messages', JSON.stringify([message]))
	}
}
const dummyGetApi = (): Message[] => {
	const res = getDummyResponses()
	if (res) {
		return res
	}
	return []
}

const dummyPostApi = async (message: Message): Promise<void> => {
	const { name, email, message: msg } = message
	if (!name || !email || !msg) {
		throw new Error('Invalid message')
	}
	const res = updateDummyResponses(message)
	return res
}

const deleteDummyResponses = (index: number): void => {
	const currentMessages = getDummyResponses()
	if (currentMessages) {
		if (index > currentMessages.length) {
			throw new Error('Index out of range')
		}
		const newMessages = currentMessages.filter((_, i) => i !== index)
		window.localStorage.setItem('messages', JSON.stringify(newMessages))
	}
}
const dummyDeleteApi = async (id: number): Promise<void> => {
	const res = await Promise.resolve(deleteDummyResponses(id))
	return res
}
export const useMessages = () =>
	useQuery({
		queryKey: ['messages'],
		queryFn: dummyGetApi,
		refetchInterval: 1000,
	})

export const useUpdateMessages = (queryClient: QueryClient) =>
	useMutation({
		mutationFn: dummyPostApi,
		onSuccess: () => {
			toast.success('Message sent!')
			queryClient.invalidateQueries({ queryKey: ['messages'] })
		},
		onError: () => {
			toast.error('Failed to send message')
		},
	})

export const useDeleteMessage = (queryClient: QueryClient) =>
	useMutation({
		mutationFn: dummyDeleteApi,
		onSuccess: () => {
			toast.success('Message deleted!')
			queryClient.invalidateQueries({ queryKey: ['messages'] })
		},
		onError: () => {
			toast.error('Failed to delete message')
		},
	})
