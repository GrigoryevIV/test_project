import React, { useEffect, useState } from 'react'

export default function App(){
  const [users, setUsers] = useState([]);
  useEffect(() => {
    fetch('/api/users')
      .then(r => r.json())
      .then(setUsers)
      .catch(console.error);
  }, []);
  return (
    <div style={{fontFamily:'Arial, Helvetica, sans-serif', padding:20}}>
      <h1>Coolify Fullstack Example</h1>
      <p>This frontend calls <code>/api/users</code> (proxied to backend).</p>
      <ul>
        {users.map(u => <li key={u.id}>{u.name} — {u.email}</li>)}
      </ul>
    </div>
  )
}