import Counter from './components/Counter';
import InputForm from './components/InputForm';
import TodoList from './components/TodoList';
import ApiFetch from './components/ApiFetch';
import ComponentReuse from './components/ComponentReuse';

function App() {
  return (
    <div className="App">
      <h1>React Applications Task</h1>
      <p style={{ marginBottom: '3rem', color: '#94a3b8' }}>
        A collection of basic React applications demonstrating state, effects, lists, and reusable components.
      </p>

      <div className="grid-container">
        <Counter />
        <InputForm />
        <TodoList />
        <ApiFetch />
        <ComponentReuse />
      </div>
    </div>
  );
}

export default App;
