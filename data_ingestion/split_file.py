import os

def split_jsonl(input_file, output_dir="split_parts", max_lines_per_file=50000):
    os.makedirs(output_dir, exist_ok=True)

    with open(input_file, "r", encoding="utf-8") as infile:
        part = 1
        line_count = 0
        outfile = open(os.path.join(output_dir, f"part_{part:03d}.jsonl"), "w", encoding="utf-8")

        for line in infile:
            if line_count >= max_lines_per_file:
                outfile.close()
                part += 1
                line_count = 0
                outfile = open(os.path.join(output_dir, f"part_{part:03d}.jsonl"), "w", encoding="utf-8")
            
            outfile.write(line)
            line_count += 1

        outfile.close()

    print(f"✅ Arquivo dividido em {part} parte(s) na pasta '{output_dir}'")


split_jsonl("./data/events.jsonl")