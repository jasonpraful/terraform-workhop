

// make api call to chat gpt and console log the response. 
// the input is obtained when running the program ex: node chatGPT.js "hello"

const API_KEY = process.env.OPENAI_API_KEY

async function chatGPT(message) {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${API_KEY}`
        },
        body: JSON.stringify({
            'model': 'gpt-3.5-turbo',
            'messages': [
                {
                    'role': 'system',
                    'content': 'Keep the answers limited to 1-4 sentences.'
                },
                {
                    'role': 'user',
                    'content': message
                }
            ]
        })
    })

    const data = await response.json()
    // console.log with color red
    console.log('\x1b[31m%s\x1b[0m', 'GPT 3.5:')
    data.choices[0].message.content.split('\n').forEach(line => console.log(line))

}


chatGPT(process.argv[2])
