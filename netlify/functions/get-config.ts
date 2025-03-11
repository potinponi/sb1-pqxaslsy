import { Handler } from '@netlify/functions';

const handler: Handler = async (event) => {
  const chatbotId = event.path.split('/').pop();

  if (!chatbotId) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: 'Missing chatbot ID' })
    };
  }

  // Return Supabase configuration
  return {
    statusCode: 200,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': process.env.ALLOWED_ORIGINS || '*',
      'Access-Control-Allow-Methods': 'GET'
    },
    body: JSON.stringify({
      supabaseUrl: process.env.VITE_SUPABASE_URL
    })
  };
};

export { handler };