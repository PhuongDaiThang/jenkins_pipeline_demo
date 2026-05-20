export type HelloResponse = {
  message: string
  source: string
  time: string
}

export async function fetchHello(): Promise<HelloResponse> {
  const response = await fetch('/api/hello')

  if (!response.ok) {
    throw new Error(`Backend returned HTTP ${response.status}`)
  }

  return response.json()
}
