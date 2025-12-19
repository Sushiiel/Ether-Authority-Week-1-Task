import { useState, useEffect } from 'react';

const ApiFetch = () => {
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(false);

    const fetchData = async () => {
        setLoading(true);
        try {
            const response = await fetch('https://jsonplaceholder.typicode.com/users/1');
            const jsonData = await response.json();
            setData(jsonData);
        } catch (error) {
            console.error('Error fetching data:', error);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="card">
            <h2>Simple API Fetch</h2>
            <div className="component-section">
                <button onClick={fetchData} disabled={loading}>
                    {loading ? 'Fetching...' : 'Fetch User Data'}
                </button>
                {data && (
                    <div style={{ textAlign: 'left', marginTop: '1rem', background: '#334155', padding: '1rem', borderRadius: '8px', fontSize: '0.9em' }}>
                        <p><strong>Name:</strong> {data.name}</p>
                        <p><strong>Email:</strong> {data.email}</p>
                        <p><strong>City:</strong> {data.address.city}</p>
                        <p><strong>Company:</strong> {data.company.name}</p>
                    </div>
                )}
            </div>
        </div>
    );
};

export default ApiFetch;
