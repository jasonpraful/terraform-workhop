import {
	DeleteItemCommand,
	DynamoDBClient,
	PutItemCommand,
	ScanCommand,
} from '@aws-sdk/client-dynamodb'
import { unmarshall } from '@aws-sdk/util-dynamodb'
import { APIGatewayProxyResult } from 'aws-lambda'

import { Message } from '../types/message.types'

export const handleGet = async (
	client: DynamoDBClient,
): Promise<APIGatewayProxyResult> => {
	const response = await client.send(
		new ScanCommand({ TableName: process.env.TABLE_NAME }),
	)
	const items = response.Items?.map((item) => unmarshall(item))
	return {
		statusCode: 200,
		body: JSON.stringify({
			items,
		}),
		headers: {
			'Access-Control-Allow-Origin': '*',
			'content-type': 'application/json',
		},
	}
}

export const handlePost = async (
	client: DynamoDBClient,
	body: Message,
): Promise<APIGatewayProxyResult> => {
	const { name, email, message } = body
	if (!name || !email || !message) {
		return {
			statusCode: 400,
			body: JSON.stringify({
				message:
					'Phew, you almost got me there. You need to send a complete body.',
				debug: 'The body needs to contain name, email, and message.',
			}),
		}
	}

	const params = {
		TableName: process.env.TABLE_NAME,
		Item: {
			id: { N: Date.now().toString() },
			name: { S: name },
			email: { S: email },
			message: { S: message },
		},
	}
	const command = new PutItemCommand(params)
	await client.send(command)
	return {
		statusCode: 200,
		body: 'Congratulations! You sent a message. Now here is a cookie 🍪',
	}
}

export const handleDelete = async (
	client: DynamoDBClient,
	id: string,
): Promise<APIGatewayProxyResult> => {
	if (!id) {
		return {
			statusCode: 400,
			body: JSON.stringify({
				message: 'Silly you, you need to send an id to delete a message.',
			}),
		}
	}
	const command = new DeleteItemCommand({
		TableName: process.env.TABLE_NAME,
		Key: {
			id: { N: id.toString() },
		},
	})
	const response = await client.send(command)
	if (response.$metadata.httpStatusCode !== 200) {
		return {
			statusCode: 500,
			body: JSON.stringify({
				message: 'Things went wrong here when trying to delete the message.',
				metadata: JSON.stringify(response.$metadata),
			}),
		}
	}

	return {
		statusCode: 200,
		body: 'You did it! The message is gone. 🎉',
	}
}
