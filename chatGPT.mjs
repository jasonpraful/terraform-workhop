const API_KEY = process.env.OPENAI_API_KEY

async function fetchGPTResponse(message) {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${API_KEY}`
        },
        body: JSON.stringify({
            model: 'gpt-3.5-turbo',
            messages: [
                {
                    role: 'system',
                    content: 'Keep the answers limited to 1-4 sentences.'
                },
                {
                    role: 'user',
                    content: message
                }
            ]
        })
    })

    return response.json()
}

async function chatGPT(message) {
    if (!message) {
        console.log(
            'Usage: node chatGPT.mjs "What came first, the chicken or the egg?"'
        )
        return
    }
    const data = await fetchGPTResponse(message)
    console.log('\x1b[31m%s\x1b[0m', 'GPT 3.5:')
    data.choices[0].message.content.split('\n').forEach((line) => {
        console.log(line)
    })
}

chatGPT(process.argv[2])
