import ttkbootstrap as ttk
from ttkbootstrap.constants import (
    BOTH,
    YES,
    INFO,
    CENTER,
    SUCCESS,
    X,
    TOP,
    DANGER,
    LEFT,
    OUTLINE,
)


class ScreenTime(ttk.Frame):
    def __init__(self, master) -> None:
        super().__init__(master, padding=10)
        self.pack(fill=BOTH, expand=YES)
        # Example ttk vars
        # self.running = ttk.BooleanVar(value=False)
        # self.afterid = ttk.StringVar()
        # self.elapsed = ttk.IntVar()
        self.main_text = ttk.StringVar(value="Screen time")

        self.create_main_label()
        self.create_app_controls()

    def create_main_label(self):
        """Main app label"""
        lbl = ttk.Label(
            master=self,
            font="-size 32",
            anchor=CENTER,
            textvariable=self.main_text,
        )
        # add label to app
        lbl.pack(side=TOP, fill=X, padx=60, pady=20)

    def create_app_controls(self):
        """Main app control buttons"""
        container = ttk.Frame(self, padding=10)
        # add frame to app.
        container.pack(fill=X)
        self.buttons = []
        # add buttons to list
        self.buttons.append(
            ttk.Button(
                master=container,
                text="Quit",
                width=10,
                bootstyle=SUCCESS,
                command=self.on_quit,
            )
        )
        # add buttons to frame
        for button in self.buttons:
            button.pack(side=LEFT, fill=X, expand=YES, pady=10, padx=5)

    def on_quit(self):
        """On quit event"""
        self.quit()


def main():
    """
    Run the app.
    """
    app = ttk.Window(
        title="Screen Time App",
        themename="darkly",
        size=(450, 450),
        resizable=(False, False),
    )
    ScreenTime(app)
    app.mainloop()


if "__main__" in __name__:
    main()
