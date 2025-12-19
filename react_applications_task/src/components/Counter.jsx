import { useState } from 'react';

const Counter = () => {
  const [count, setCount] = useState(0);

  return (
    <div className="card">
      <h2>Counter App</h2>
      <div className="component-section">
        <p style={{ fontSize: '2rem', fontWeight: 'bold' }}>{count}</p>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button onClick={() => setCount(count - 1)}>Decrease</button>
          <button onClick={() => setCount(count + 1)}>Increase</button>
        </div>
        <button 
          onClick={() => setCount(0)} 
          style={{ backgroundColor: '#ef4444', marginTop: '10px' }}
        >
          Reset
        </button>
      </div>
    </div>
  );
};

export default Counter;
