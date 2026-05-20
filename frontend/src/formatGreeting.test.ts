import { describe, expect, it } from 'vitest'
import { formatGreeting } from './formatGreeting'

describe('formatGreeting', () => {
  it('formats backend message and source', () => {
    expect(formatGreeting('Hello', 'backend')).toBe('Hello - served by backend')
  })
})
