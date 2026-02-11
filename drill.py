#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.14"
# dependencies = [
#     "rich>=14.2.0",
#     "cyclopts>=2.9.0",
# ]
# ///
"""
🎰🔮 NEO-TOKYO PACHINKO PROTOCOL v99.99 🔮🎰
⚠️ WARNING: EPILEPSY HAZARD // LOW-RES DREAMS // HIGH-TECH TRASH ⚠️
The test is tomorrow?! Whatever.  ( ˘︹˘ )
🧠 MODE: CHAOS // 📅 DEADLINE: ??? // 💎 STATUS: GLITCHED
"""

import json
import random
import shutil
import subprocess
import time
from datetime import timedelta
from pathlib import Path
from typing import Annotated

import cyclopts
from rich import box
from rich.console import Console
from rich.markdown import Markdown
from rich.panel import Panel
from rich.style import Style
from rich.table import Table
from rich.theme import Theme

# 🎰 WASHED-OUT NEON TRASH PALETTE 🎰
# No hard reds. Just weird vibes.
PALETTE = {
    "void": "#2a2a2a",  # Ugly grey
    "static": "#d4d4d4",  # Dirty white
    "slime": "#ccff00",  # Radioactive piss color
    "plastic": "#ff69b4",  # Cheap toy pink
    "glitch": "#00ffff",  # Eye-searing cyan
    "rust": "#cd7f32",  # Decayed bronze
    "mold": "#00fa9a",  # Medium spring green
    "bruise": "#9370db",  # Medium purple
    "faded": "#708090",  # Slate grey
    "gold_leaf": "#ffd700",  # Fake gold
}

# 🎰 TRASH_THEME.EXE 🎰
custom_theme = Theme(
    {
        "info": Style(color=PALETTE["glitch"], bold=True, bgcolor=PALETTE["void"]),
        "warning": Style(color=PALETTE["plastic"], bold=True, italic=True),
        "error": Style(color=PALETTE["rust"], bold=True, bgcolor=PALETTE["static"]),
        "success": Style(color=PALETTE["slime"], bold=True, underline=True),
        "header": Style(color=PALETTE["void"], bold=True, bgcolor=PALETTE["gold_leaf"]),
        "drill.name": Style(color=PALETTE["plastic"], bold=True),
        "drill.category": Style(color=PALETTE["bruise"], italic=True),
        "highlight": Style(color=PALETTE["void"], bold=True, bgcolor=PALETTE["mold"]),
        "cosmic": Style(color=PALETTE["plastic"], blink=True, bold=True),
        "warp": Style(color=PALETTE["glitch"], reverse=True),
    }
)

console = Console(theme=custom_theme)
DRILLS_DIR = Path("drills")
STATE_FILE = Path.home() / ".drill_record.json"

app = cyclopts.App(help="🎰💊 CKA PACHINKO PARLOR — INSERT TOKEN 💊🎰")


class Drill:
    def __init__(self, category: str, name: str, path: Path):
        self.category = category
        self.name = name
        self.path = path
        self.setup_script = path / "setup.sh"
        self.verify_script = path / "verify.sh"
        self.problem_file = path / "problem.md"

    @property
    def full_name(self) -> str:
        return f"{self.category}/{self.name}"

    def exists(self) -> bool:
        return self.path.exists()

    def has_setup(self) -> bool:
        return self.setup_script.exists()

    def has_verify(self) -> bool:
        return self.verify_script.exists()

    def get_problem_text(self) -> str:
        if self.problem_file.exists():
            return self.problem_file.read_text()
        return "👻 404 NOT FOUND 👻 The spirits ate your homework. (problem.md missing)"


class DrillManager:
    def __init__(self):
        self.drills: list[Drill] = []
        self.completed_drills: list[str] = []
        self.started_drills: list[str] = []
        self.archived_drills: list[str] = []
        self.drill_start_times: dict[str, float] = {}
        self._load_drills()
        self._load_state()

    def _load_drills(self):
        if not DRILLS_DIR.exists():
            return

        for category_dir in DRILLS_DIR.iterdir():
            if category_dir.is_dir() and not category_dir.name.startswith("."):
                for drill_dir in category_dir.iterdir():
                    if drill_dir.is_dir() and not drill_dir.name.startswith("."):
                        self.drills.append(Drill(category_dir.name, drill_dir.name, drill_dir))

        # Sort by category then name
        self.drills.sort(key=lambda d: (d.category, d.name))

    def _load_state(self):
        if STATE_FILE.exists():
            try:
                with open(STATE_FILE, "r") as f:
                    data = json.load(f)
                    self.completed_drills = data.get("completed", [])
                    self.started_drills = data.get("started", [])
                    self.archived_drills = data.get("archived", [])
                    self.drill_start_times = data.get("start_times", {})
            except json.JSONDecodeError:
                self.completed_drills = []
                self.started_drills = []
                self.archived_drills = []
                self.drill_start_times = {}
        else:
            self.started_drills = []
            self.drill_start_times = {}
            self.completed_drills = []
            self.archived_drills = []

    def save_state(self):
        data = {
            "completed": self.completed_drills,
            "started": self.started_drills,
            "archived": self.archived_drills,
            "start_times": self.drill_start_times,
        }
        with open(STATE_FILE, "w") as f:
            json.dump(data, f)

    def mark_completed(self, drill_name: str):
        if drill_name not in self.completed_drills:
            self.completed_drills.append(drill_name)

        if drill_name in self.started_drills:
            self.started_drills.remove(drill_name)

        self.save_state()

    def mark_started(self, drill_name: str):
        if drill_name not in self.started_drills and drill_name not in self.completed_drills:
            self.started_drills.append(drill_name)

        # Always update start time when starting/restarting
        self.drill_start_times[drill_name] = time.time()
        self.save_state()

    def archive_completed(self):
        """💿 Burn data to LaserDisc 💿"""
        count = 0
        for drill in list(self.completed_drills):  # Iterate over a copy
            if drill not in self.archived_drills:
                self.archived_drills.append(drill)
                self.completed_drills.remove(drill)
                count += 1
        self.save_state()
        return count

    def reset_in_progress(self):
        """🧹 KICK THE PLUG OUT 🧹"""
        self.started_drills = []
        self.save_state()

    def reset_all(self):
        """💣 SYSTEM CRASH 💣"""
        self.started_drills = []
        self.completed_drills = []
        self.archived_drills = []
        self.drill_start_times = {}
        self.save_state()

    def get_drill(self, name: str) -> Drill | None:
        for drill in self.drills:
            if drill.full_name == name:
                return drill
        return None

    def get_drills_by_category(self) -> dict[str, list[Drill]]:
        result = {}
        for drill in self.drills:
            if drill.category not in result:
                result[drill.category] = []
            result[drill.category].append(drill)
        return result

    def get_unstarted_drills(self) -> list[Drill]:
        """🚬 Unplayed Levels"""
        done_list = self.completed_drills + self.archived_drills
        return [
            d
            for d in self.drills
            if d.full_name not in self.started_drills and d.full_name not in done_list
        ]

    def get_body_count(self) -> int:
        """💯 High Score"""
        return len(self.completed_drills) + len(self.archived_drills)

    def abandon(self, drill_name: str) -> bool:
        drill = self.get_drill(drill_name)
        if not drill:
            return False

        drill_path = drill.path.resolve()
        drills_root = DRILLS_DIR.resolve()
        if drills_root not in drill_path.parents:
            raise RuntimeError(f"Refusing to delete path outside drills directory: {drill_path}")

        if drill_path.exists():
            shutil.rmtree(drill_path)

        if drill_name in self.completed_drills:
            self.completed_drills.remove(drill_name)
        if drill_name in self.started_drills:
            self.started_drills.remove(drill_name)
        if drill_name in self.archived_drills:
            self.archived_drills.remove(drill_name)
        if drill_name in self.drill_start_times:
            self.drill_start_times.pop(drill_name, None)

        self.drills = [d for d in self.drills if d.full_name != drill_name]
        self.save_state()
        return True


# ⚡ COMMS RELAY ⚡
def run_remote_script(script_path: Path) -> bool:
    """📠 DIALING UP MODEM TO CONTROL PLANE... 📠"""
    cmd = f"vagrant ssh ubukubu-control -- 'bash -s' < {script_path}"
    console.print(
        f"[bold {PALETTE['faded']}]... uploading [bold {PALETTE['glitch']}]{script_path.name}[/] via loose cable ...[/]"
    )
    return subprocess.call(cmd, shell=True) == 0


manager = DrillManager()


@app.command(name="list")
def list_drills(
    show_all: Annotated[
        bool,
        cyclopts.Parameter(
            name=["--show-all", "--all", "--history"],
            help="Show ancient history (the before times)",
        ),
    ] = False,
):
    """Peek at the menu"""
    console.print(
        Panel.fit(
            f"[header] 🍟  M E N U   O P T I O N S  🍟 [/]",
            border_style=PALETTE["rust"],
        )
    )

    if not manager.drills:
        console.print(f"[error]🤷 EMPTY FRIDGE — No drills found[/]")
        return

    # Completion Display
    completion_count = manager.get_body_count()
    if completion_count > 0:
        tier = (
            "👽 SUPREME BEING"
            if completion_count >= 200
            else "🤖 CYBORG"
            if completion_count >= 100
            else "🐀 RAT"
        )
        stars = "✦" * min(completion_count // 20, 10)
        console.print(
            f"[bold {PALETTE['gold_leaf']}]{tier} STATUS — {completion_count} shiny things collected {stars}[/]"
        )

    table = Table(
        box=box.ASCII,
        border_style=PALETTE["faded"],
        header_style=f"bold {PALETTE['plastic']}",
        show_lines=True,
        pad_edge=False,
        title=f"[{PALETTE['glitch']}]SYSTEM_ROOT/GAMES.EXE[/]",
        title_justify="left",
    )
    table.add_column("S T A T U S", justify="center", style="bold")
    table.add_column("Z O N E", style="drill.category")
    table.add_column("T A R G E T", style="drill.name")

    drills_by_cat = manager.get_drills_by_category()

    visible_count = 0
    for category in sorted(drills_by_cat.keys()):
        for drill in drills_by_cat[category]:
            is_completed = drill.full_name in manager.completed_drills
            is_archived = drill.full_name in manager.archived_drills
            is_started = drill.full_name in manager.started_drills

            # Filtering logic:
            if not show_all and (is_completed or is_archived):
                continue

            visible_count += 1

            if is_completed:
                status = f"[{PALETTE['slime']}]✨ DONE-ZO"
            elif is_archived:
                status = f"[{PALETTE['faded']}]📼 TAPE"
            elif is_started:
                status = f"[{PALETTE['glitch']}]🔥 LIT"
            else:
                status = f"[{PALETTE['plastic']}]💤 ZZZ"

            table.add_row(status, drill.category, drill.name)

    if visible_count == 0:
        console.print(
            f"\n[{PALETTE['slime']}]"
            f"  🎰  J A C K P O T  🎰\n"
            f"  You cleared the board! Go nap.\n"
            f"  (use --show-all to relive the trauma)[/]\n"
        )
    else:
        console.print(table)
        console.print(
            f"\n[{PALETTE['faded']}]  ▸ [bold]drill start <zone/target>[/] — coin drop\n"
            f"  ▸ [bold]drill random[/]                   — chaos mode (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧[/]"
        )


@app.command
def start(drill_name: str):
    """Press Start 2 Play"""
    drill = manager.get_drill(drill_name)
    if not drill:
        console.print(
            f"[error]🚫 IDK MAN — '{drill_name}' ain't real.\nRun [bold]drill list[/] maybe??[/]"
        )
        return

    console.print(f"[info]💿 LOADING [bold]{drill.full_name}[/]... please wait or don't...[/info]")

    if not drill.has_setup():
        console.print(f"[error]🐌 FILE CORRUPT — setup.sh fell off the truck[/]")
        return

    if run_remote_script(drill.setup_script):
        manager.mark_started(drill.full_name)
        console.print(
            Panel(
                Markdown(drill.get_problem_text()),
                title=f"[header] 📺 BREAKING NEWS :: {drill.name} [/]",
                subtitle=f"[{PALETTE['glitch']}]SOMETHING BROKE LOL[/]",
                border_style=PALETTE["plastic"],
                expand=False,
            )
        )
        console.print(
            f"\n[{PALETTE['gold_leaf']}]"
            f"  ╭──────────────────────────────────────────╮\n"
            f"  │  👾  A  W I L D   B U G   AP P E A R S │\n"
            f"  │                                          │\n"
            f"  │  > FIX IT                                │\n"
            f"  │  > CRY ABOUT IT                          │\n"
            f"  │  > REBOOT                                │\n"
            f"  ╰──────────────────────────────────────────╯"
            f"[/]"
        )
    else:
        console.print(f"[error]💥 KABOOM — setup.sh died screaming[/]")


@app.command(name="random", alias=["random-drill"])
def random_drill():
    """RNG GODS PRAYER"""
    unstarted = manager.get_unstarted_drills()
    if not unstarted:
        console.print(
            Panel(
                f"[bold {PALETTE['slime']}]🏆 YOU WIN! 🏆\n"
                f"[{PALETTE['static']}]... I guess? Go outside.\n"
                f"Touch grass.[/]",
                border_style=PALETTE["gold_leaf"],
                expand=False,
            )
        )
        return

    drill = random.choice(unstarted)
    console.print(
        f"\n[{PALETTE['plastic']}]🎲 ROLLIN' THEM BONES... you got:[/]\n"
        f" >> [bold {PALETTE['glitch']}]{drill.full_name}[/] "
        f"\n"
    )
    start(drill.full_name)


@app.command
def verify(drill_name: Annotated[str | None, cyclopts.Parameter()] = None):
    """JUDGEMENT DAY"""

    # If a specific drill is requested
    if drill_name:
        _verify_single(drill_name)
        return

    # Otherwise verify all started
    started = manager.started_drills.copy()
    if not started:
        console.print(f"[info]💤 No active games. Insert Coin.[/]")
        return

    console.print(
        Panel.fit(
            f"[header] ⚖️  J U D G E M E N T   Z O N E  ⚖️ [/]",
            border_style=PALETTE["bruise"],
        )
    )

    passed_count = 0
    failed_count = 0
    for d_name in started:
        if _verify_single(d_name):
            passed_count += 1
        else:
            failed_count += 1
        console.print()

    # Summary
    if failed_count == 0:
        summary_panel = Panel(
            f"[bold {PALETTE['slime']}]NICE! {passed_count}/{passed_count} verified.[/]\n"
            f"[{PALETTE['static']}]You're a wizard, Harry.[/]",
            border_style=PALETTE["slime"],
        )
    else:
        summary_panel = Panel(
            f"[bold {PALETTE['static']}]RESULTS[/]\n\n"
            f"  [{PALETTE['slime']}]✔ {passed_count} GOOD[/]   [{PALETTE['rust']}]✖ {failed_count} BAD[/]\n\n"
            f"[{PALETTE['plastic']}]  (╯°□°）╯︵ ┻━┻[/]",
            border_style=PALETTE["rust"],
        )
    console.print(summary_panel)


def _verify_single(drill_name: str) -> bool:
    drill = manager.get_drill(drill_name)
    if not drill:
        console.print(f"[error]🚫 WHO DAT? '{drill_name}'[/]")
        return False

    if not drill.has_verify():
        console.print(f"[error]🚫 verify.sh missing? Sus.[/]")
        return False

    console.print(f"[info]Poking [bold]{drill.full_name}[/]...[/info]")

    if run_remote_script(drill.verify_script):
        elapsed_msg = ""
        if drill.full_name in manager.drill_start_times:
            start_time = manager.drill_start_times[drill.full_name]
            elapsed = time.time() - start_time
            elapsed_str = str(timedelta(seconds=int(elapsed)))
            elapsed_msg = f" [dim]({elapsed_str})[/dim]"

        console.print(
            Panel(
                f"[bold {PALETTE['slime']}]✨ FLAVOR TEXT: SUCCESS! — {drill.name}[/]{elapsed_msg}",
                style=f"black on {PALETTE['slime']}",
                expand=False,
            )
        )
        manager.mark_completed(drill.full_name)
        return True
    else:
        console.print(
            Panel(
                f"[bold {PALETTE['void']}]💀 GAME OVER — {drill.name}",
                style=f"black on {PALETTE['rust']}",
                expand=False,
            )
        )
        return False


@app.command
def reset(
    active: Annotated[bool, cyclopts.Parameter(name=["--active"], help="Kill active runs")] = False,
    all: Annotated[
        bool, cyclopts.Parameter(name=["--all"], help="CAUTION: NUKE EVERYTHING")
    ] = False,
):
    """Rage Quit"""
    if active and all:
        console.print(f"[error]Bruh. --active OR --all.[/]")
        return

    if active:
        manager.reset_in_progress()
        console.print(
            Panel(
                f"[bold {PALETTE['glitch']}]Active quests abandoned.",
                border_style=PALETTE["faded"],
                expand=False,
            )
        )
    elif all:
        manager.reset_all()
        console.print(
            Panel(
                f"[bold {PALETTE['rust']}]🧨  BIG BADDA BOOM  🧨[/]\n\n"
                f"[{PALETTE['static']}]  Memory wiped. Good luck.[/]",
                border_style=PALETTE["rust"],
                expand=False,
            )
        )
    else:
        console.print(f"[warning]Pick one! --active or --all[/]")


@app.command
def archive():
    """Put stuff in the attic"""
    count = manager.archive_completed()
    if count > 0:
        console.print(
            Panel(
                f"[bold {PALETTE['bruise']}]Stashed {count} things in the basement.",
                border_style=PALETTE["plastic"],
                expand=False,
            )
        )
    else:
        console.print(f"[dim]Empty hands, empty heart.[/dim]")


@app.command
def abandon(drill_name: str):
    """Yeet into the sun"""
    if manager.abandon(drill_name):
        console.print(
            Panel(
                f"[bold {PALETTE['rust']}]🗑️  {drill_name} has been deleted from existence.[/]",
                border_style=PALETTE["void"],
                expand=False,
            )
        )
    else:
        console.print(f"[error]404 on '{drill_name}'[/]")


if __name__ == "__main__":
    app()
