import { useQueryClient } from '@tanstack/react-query'
import { useRef } from 'react'

import { useUpdateMessages } from '@/services/queries/messages.query'

const MessageForm = () => {
	const queryClient = useQueryClient()
	const formRef = useRef<HTMLFormElement>(null)
	const { mutateAsync, isPending } = useUpdateMessages(queryClient)

	const handleSubmit = async (event: React.FormEvent<HTMLFormElement>) => {
		event.preventDefault()
		const formData = new FormData(event.currentTarget)
		const name = formData.get('name') as string
		const email = formData.get('email') as string
		const message = formData.get('message') as string
		try {
			await mutateAsync({ name, email, message })
			formRef.current?.reset()
		} catch (error) {
			console.error(error)
		}
	}

	return (
		<form
			ref={formRef}
			onSubmit={handleSubmit}
			className="col-span-1 h-[50vh] items-start justify-center rounded-lg border border-gray-500 p-5 pt-2 shadow-lg"
		>
			<div className="flex w-full flex-col">
				<label htmlFor="name" className="text-lg font-semibold">
					Name
				</label>
				<input
					type="text"
					id="name"
					name="name"
					aria-label="Name"
					autoFocus
					className="mb-4 rounded-lg border border-gray-500 p-2"
				/>
				<label htmlFor="email" className="text-lg font-semibold">
					Email
				</label>
				<input
					type="email"
					id="email"
					name="email"
					aria-label="Email"
					className="mb-4 rounded-lg border border-gray-500 p-2"
				/>
				<label htmlFor="message" className="text-lg font-semibold">
					Message
				</label>
				<textarea
					id="message"
					name="message"
					className="mb-4 rounded-lg border border-gray-500 p-2"
				/>
				<button
					type="submit"
					className="rounded-lg bg-blue-500 p-2 text-white"
					aria-label="Submit"
					disabled={isPending}
				>
					Submit
				</button>
			</div>
		</form>
	)
}

export default MessageForm
