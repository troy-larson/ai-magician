import argparse

from dotenv import dotenv_values
from textual.app import App, ComposeResult
from textual.containers import Container
from textual.widgets import Button, Input, Static


def load_env_vars(env_path):
    return dotenv_values(env_path)


def save_env_vars(env_vars, env_path):
    with open(env_path, "w") as f:
        for key, value in env_vars.items():
            f.write(f"{key}={value}\n")


class EnvVarFormApp(App):

    def __init__(self, env_path=".env"):
        super().__init__()
        self.env_path = env_path

    def compose(self) -> ComposeResult:
        env_vars = load_env_vars(self.env_path)
        self.inputs = {}
        with Container():
            for key, value in env_vars.items():
                if "PASSWORD" in key:
                    value = "******"  # Mask passwords
                label = Static(f"{key}:")
                input_field = Input(value=value, name=key)
                self.inputs[key] = input_field
                yield label
                yield input_field
            yield Button("Save", id="save")

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "save":
            answers = {name: inp.value for name, inp in self.inputs.items()}
            save_env_vars(answers, self.env_path)
            print("Environment variables saved.")
            self.exit()


def main():
    parser = argparse.ArgumentParser(description="Environment Variable Form App")
    parser.add_argument(
        "--env-path",
        type=str,
        default=".env",
        help="Path to the .env file",
    )
    args = parser.parse_args()

    app = EnvVarFormApp(args.env_path)
    app.run()


if __name__ == "__main__":
    main()
