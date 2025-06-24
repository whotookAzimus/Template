import os

def count_lines_in_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        return sum(1 for _ in file)

def count_lines_in_directory(directory, exclude_packages=False):
    total_lines = 0

    for root, dirs, files in os.walk(directory):
        if exclude_packages and "Packages" in root.split(os.sep):
            continue
        for file in files:
            if file.endswith('.lua') or file.endswith('.luau'):
                file_path = os.path.join(root, file)
                total_lines += count_lines_in_file(file_path)

    return total_lines

if __name__ == "__main__":
    total_lines_excluding_packages = count_lines_in_directory('src', exclude_packages=True)
    print(f"Total lines in 'src' directory (excluding 'Packages'): {total_lines_excluding_packages}")
