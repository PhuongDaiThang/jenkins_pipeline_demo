import { useEffect, useState } from 'react'
import { fetchHello, type HelloResponse } from './api'
import { formatGreeting } from './formatGreeting'

export default function App() {
  const [data, setData] = useState<HelloResponse | null>(null)
  const [error, setError] = useState<string>('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchHello()
      .then(setData)
      .catch((err: unknown) => {
        const message = err instanceof Error ? err.message : 'Unknown error'
        setError(message)
      })
      .finally(() => setLoading(false))
  }, [])

  return (
    <main className="page">
      <section className="card">
        <p className="eyebrow">CI/CD learning project</p>
        <h1>Jenkins Multibranch Demo</h1>
        <p className="description">
          This tiny app is designed for testing Jenkins Pipeline stages: backend test,
          backend package, frontend test, frontend build, Docker build, and local deploy.
        </p>

        <div className="result-box">
          {loading && <p>Calling backend...</p>}
          {error && <p className="error">Backend error: {error}</p>}
          {data && (
            <>
              <p className="success">{formatGreeting(data.message, data.source)}</p>
              <small>Backend time: {new Date(data.time).toLocaleString()}</small>
            </>
          )}
        </div>
      </section>
    </main>
  )
}
