import re
import networkx as nx
import matplotlib.pyplot as plt

def parse_ahk_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as file:
        lines = file.readlines()
    
    # Regex to match a function definition. This expects a definition like:
    # functionName()
    # {
    # ...
    # }
    func_def_pattern = re.compile(r'^\s*(\w+)\s*\(\s*\)\s*{')
    # Regex to match a function call (assumes no parameters)
    call_pattern = re.compile(r'(\w+)\s*\(\s*\)')
    
    functions = {}
    current_function = None
    brace_count = 0

    for line in lines:
        line = line.strip()
        # If not inside a function, try to match a definition
        if current_function is None:
            match = func_def_pattern.match(line)
            if match:
                current_function = match.group(1)
                functions[current_function] = []
                brace_count = 1
                print(f"Found function definition: {current_function}")
        else:
            # We are inside a function: update brace count to determine when it ends.
            brace_count += line.count('{')
            brace_count -= line.count('}')
            # Find all calls on this line
            calls = call_pattern.findall(line)
            # Remove self-call if present (optional) and add only unique calls.
            for call in calls:
                # Avoid counting the function definition line as a call
                if call != current_function:
                    functions[current_function].append(call)
                    print(f"In function {current_function}, found call: {call}")
            # When brace count reaches zero, we leave the current function.
            if brace_count <= 0:
                print(f"End of function: {current_function}")
                current_function = None

    return functions

def get_dependencies(functions, target_function):
    """Recursively collect all dependencies for target_function."""
    dependencies = set()
    stack = [target_function]
    
    while stack:
        func = stack.pop()
        if func not in dependencies:
            dependencies.add(func)
            # If the function is defined in our parsed mapping, add its calls
            if func in functions:
                for call in functions[func]:
                    stack.append(call)
    return dependencies

def create_dependency_graph(functions, target_function):
    graph = nx.DiGraph()
    deps = get_dependencies(functions, target_function)

    # Add nodes (all dependencies are nodes)
    for func in deps:
        graph.add_node(func)
    # Add edges: only add an edge if both functions exist and are in the dependency subtree.
    for func in deps:
        if func in functions:
            for call in functions[func]:
                if call in deps:
                    graph.add_edge(func, call)
    return graph

def plot_dependency_graph(graph):
    pos = nx.spring_layout(graph)
    plt.figure(figsize=(12,8))
    nx.draw(graph, pos, with_labels=True, node_size=3000, node_color='skyblue', 
            font_size=10, font_weight='bold', arrows=True)
    plt.title("Function Dependency Graph")
    plt.show()

if __name__ == "__main__":
    filepath = 'C:/Users/craig/teldig/teldig.ahk'
    target_function = 'sketchAutoFill'
    functions = parse_ahk_file(filepath)
    
    print("\nParsed Functions and their Calls:")
    for func, calls in functions.items():
        print(f"{func} -> {calls}")
    
    if target_function not in functions:
        print(f"\nError: Function {target_function} was not found in the parsed functions")
    else:
        deps = get_dependencies(functions, target_function)
        print(f"\nAll dependencies for {target_function}: {deps}")
        graph = create_dependency_graph(functions, target_function)
        plot_dependency_graph(graph)