import { QueryClient, useMutation, useQuery } from '@tanstack/react-query'
import toast from 'react-hot-toast'

import { deleteMessage, getMessages, postMessage } from '../api/messages.api'

export const useMessages = () =>
	useQuery({
		queryKey: ['messages'],
		queryFn: getMessages,
		refetchInterval: 3000,
	})

export const useUpdateMessages = (queryClient: QueryClient) =>
	useMutation({
		mutationFn: postMessage,
		onSuccess: (d) => {
			toast.success(d)
			queryClient.invalidateQueries({ queryKey: ['messages'] })
		},
		onError: () => {
			toast.error('Failed to send message')
		},
	})

export const useDeleteMessage = (queryClient: QueryClient) =>
	useMutation({
		mutationFn: deleteMessage,
		onSuccess: (d) => {
			toast.success(d)
			queryClient.invalidateQueries({ queryKey: ['messages'] })
		},
		onError: () => {
			toast.error('Failed to delete message')
		},
	})
