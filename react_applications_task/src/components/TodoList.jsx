import { useState } from 'react';

const TodoList = () => {
    const [todos, setTodos] = useState([]);
    const [newTodo, setNewTodo] = useState('');

    const addTodo = (e) => {
        e.preventDefault();
        if (!newTodo.trim()) return;
        setTodos([...todos, { id: Date.now(), text: newTodo, completed: false }]);
        setNewTodo('');
    };

    const toggleTodo = (id) => {
        setTodos(todos.map(todo =>
            todo.id === id ? { ...todo, completed: !todo.completed } : todo
        ));
    };

    const deleteTodo = (id) => {
        setTodos(todos.filter(todo => todo.id !== id));
    };

    return (
        <div className="card">
            <h2>Todo List App</h2>
            <form onSubmit={addTodo} className="component-section" style={{ flexDirection: 'row', marginBottom: '1rem' }}>
                <input
                    type="text"
                    value={newTodo}
                    onChange={(e) => setNewTodo(e.target.value)}
                    placeholder="New task..."
                    style={{ flex: 1 }}
                />
                <button type="submit">Add</button>
            </form>
            <ul style={{ textAlign: 'left', width: '100%' }}>
                {todos.length === 0 && <p style={{ textAlign: 'center', color: '#94a3b8' }}>No tasks yet.</p>}
                {todos.map(todo => (
                    <li key={todo.id}>
                        <span
                            onClick={() => toggleTodo(todo.id)}
                            style={{
                                textDecoration: todo.completed ? 'line-through' : 'none',
                                cursor: 'pointer',
                                color: todo.completed ? '#94a3b8' : 'white',
                                flex: 1
                            }}
                        >
                            {todo.text}
                        </span>
                        <button
                            onClick={() => deleteTodo(todo.id)}
                            style={{ padding: '0.3em 0.6em', fontSize: '0.8em', backgroundColor: '#ef4444', marginLeft: '10px' }}
                        >
                            ✕
                        </button>
                    </li>
                ))}
            </ul>
        </div>
    );
};

export default TodoList;
