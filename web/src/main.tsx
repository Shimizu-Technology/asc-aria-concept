import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { ClerkProvider } from '@clerk/clerk-react'
import './index.css'
import App from './App.tsx'

const clerkPublishableKey = import.meta.env.VITE_CLERK_PUBLISHABLE_KEY
const isClerkEnabled = Boolean(clerkPublishableKey)

const app = <App isClerkEnabled={isClerkEnabled} />

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    {isClerkEnabled ? (
      <ClerkProvider
        publishableKey={clerkPublishableKey}
        afterSignOutUrl="/"
        signInFallbackRedirectUrl="/"
        signUpFallbackRedirectUrl="/"
      >
        {app}
      </ClerkProvider>
    ) : app}
  </StrictMode>,
)
