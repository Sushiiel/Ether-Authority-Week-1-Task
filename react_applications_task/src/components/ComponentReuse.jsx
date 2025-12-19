import PropTypes from 'prop-types';

// Reusable Card Component
const InfoCard = ({ title, content, type = 'info' }) => {
    const getBorderColor = () => {
        switch (type) {
            case 'success': return '#22c55e';
            case 'warning': return '#eab308';
            case 'error': return '#ef4444';
            default: return '#3b82f6';
        }
    };

    return (
        <div style={{
            border: `1px solid ${getBorderColor()}`,
            padding: '1rem',
            borderRadius: '8px',
            background: 'rgba(255,255,255,0.05)',
            marginBottom: '0.5rem'
        }}>
            <h4 style={{ margin: '0 0 0.5rem 0', color: getBorderColor() }}>{title}</h4>
            <p style={{ margin: 0, fontSize: '0.9em' }}>{content}</p>
        </div>
    );
};

InfoCard.propTypes = {
    title: PropTypes.string.isRequired,
    content: PropTypes.string.isRequired,
    type: PropTypes.oneOf(['info', 'success', 'warning', 'error']),
};

const ComponentReuse = () => {
    return (
        <div className="card">
            <h2>Component Reuse</h2>
            <div className="component-section" style={{ alignItems: 'stretch' }}>
                <InfoCard
                    title="Information"
                    content="This is a standard informational message reusing the component."
                    type="info"
                />
                <InfoCard
                    title="Success!"
                    content="Operation completed successfully. This is the same component with a 'success' prop."
                    type="success"
                />
                <InfoCard
                    title="Warning"
                    content="Please be careful. This shows reuse with a 'warning' style."
                    type="warning"
                />
            </div>
        </div>
    );
};

export default ComponentReuse;
