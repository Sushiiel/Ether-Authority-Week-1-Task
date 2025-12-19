import { useState } from 'react';

const InputForm = () => {
    const [inputValue, setInputValue] = useState('');
    const [submittedValue, setSubmittedValue] = useState('');

    const handleSubmit = (e) => {
        e.preventDefault();
        setSubmittedValue(inputValue);
        setInputValue('');
    };

    return (
        <div className="card">
            <h2>Input Form App</h2>
            <form onSubmit={handleSubmit} className="component-section">
                <input
                    type="text"
                    value={inputValue}
                    onChange={(e) => setInputValue(e.target.value)}
                    placeholder="Type something..."
                />
                <button type="submit">Submit</button>
            </form>
            {submittedValue && (
                <div style={{ marginTop: '1rem', padding: '1rem', backgroundColor: '#334155', borderRadius: '8px', width: '100%' }}>
                    <strong>You submitted:</strong>
                    <p>{submittedValue}</p>
                </div>
            )}
        </div>
    );
};

export default InputForm;
