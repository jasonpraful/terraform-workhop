import { MessageForm, MessageList } from './components'

function App() {
	return (
		<>
			<div className="my-10 h-full overflow-hidden">
				<h1 className="text-center align-text-bottom text-4xl font-bold text-gray-900">
					<img
						className="mb-2 mr-2 inline-block h-16 w-16"
						src="/terraform.svg"
						alt="Terraform"
					/>
					VF Terraform Workshop
				</h1>
				<main>
					<div className="grid h-[50vh] grid-cols-2 content-center items-center justify-center gap-2 py-6 sm:px-6 lg:px-8">
						<MessageForm />
						<MessageList />
					</div>
				</main>
			</div>
		</>
	)
}

export default App
