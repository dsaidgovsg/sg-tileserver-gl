# test_insecure_eval.py

def run_user_code():
    # Semgrep’s python.security.insecure-eval rule will fire on this:
    user_input = input("Enter some Python code> ")
    eval(user_input)
    exec(user_input)

if __name__ == "__main__":
    run_user_code()
