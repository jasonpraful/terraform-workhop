import { DynamoDBClient } from '@aws-sdk/client-dynamodb'
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'

// Yes! The extension was intended. TSC doesn't add .js extension to the import
// when compiling to JS, so we need to add it manually.
import { handleDelete, handleGet, handlePost } from './handlers/dynamodb.js'

export const handler = async (
	event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
	try {
		const client = new DynamoDBClient({})

		if (event.httpMethod === 'POST') {
			const { body } = event
			if (!body) {
				return {
					statusCode: 400,
					body: JSON.stringify({
						message: 'Who are you trying to fool? You need to send a body.',
					}),
				}
			}
			return await handlePost(client, JSON.parse(body))
		}
		if (event.httpMethod === 'GET') {
			return await handleGet(client)
		}

		if (event.httpMethod === 'DELETE') {
			const { queryStringParameters } = event
			if (!queryStringParameters || !queryStringParameters.id) {
				return {
					statusCode: 400,
					body: JSON.stringify({
						message: "I mean, you can't delete nothing.",
					}),
				}
			}
			const id = JSON.parse(queryStringParameters.id)
			if (!id) {
				return {
					statusCode: 400,
					body: JSON.stringify({
						message: 'Well well well, looks like you forgot to include the id.',
					}),
				}
			}
			return await handleDelete(client, id)
		}
		return {
			statusCode: 400,
			body: JSON.stringify({
				message: 'Naughty naughty! This is not a valid HTTP method.',
				debug: "Acceptable methods are 'GET', 'POST', and 'DELETE'.",
			}),
		}
	} catch (err) {
		console.log(err)
		return {
			statusCode: 500,
			body: JSON.stringify({
				message: 'Oops! Something went wrong.',
				debug: JSON.stringify(err),
			}),
		}
	}
}
