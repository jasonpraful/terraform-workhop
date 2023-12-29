import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'

export const handler = async (
	event: APIGatewayProxyEvent,
): Promise<APIGatewayProxyResult> => {
	try {
		return {
			statusCode: 200,
			body: JSON.stringify({
				message: 'hello world',
				body: JSON.stringify(event.body),
			}),
		}
	} catch (err) {
		console.log(err)
		return {
			statusCode: 500,
			body: JSON.stringify({
				message: 'some error happened',
			}),
		}
	}
}