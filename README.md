# Homie Hub

A small, phone-first app for a friend group to keep a regular get-together on the calendar. It handles the recurring hangout, fair host rotation, rides, chill requests, a message board, and everyone's profiles, all in one HTML file with no build step.

Built for a group of about 3 to 8 people who trust each other. It is casual on purpose.

## What it does

**Home**
- Shows the next hangout (default: every 2 weeks on Friday at 7:00 PM, all adjustable in Settings).
- Fair host rotation. The next host is whoever has hosted the fewest times, with ties broken by who hosted longest ago. Anyone can swap the host, or choose **No host** for group outings like hikes.
- Pick the plan from the activity chips, write your own, or jump to the Ideas board.
- Add plus-ones and guests, see who can't make it, and mark the night done or skip it.
- After a skip or an event resets the schedule, tap **Change date** to pick the day the new cycle starts, or **Undo skip** to put things back. The same buttons are on that day in the Calendar.
- Ride requests and open chill requests for the upcoming date.

**Calendar**
- Month view with dots for hangouts, events, and days people are busy.
- Dots mark plans. A blue square marks work shifts and a gray x marks days someone is busy. A small amber dash marks notes. A dashed pink outline marks a chill request.
- Add "I'm busy" days, events (which can reset the biweekly schedule), and notes.
- Blackouts mark holidays and other days the group won't be together. A hangout that lands on one moves to the next regular day after it.
- Request a ride to anything on a day (an event, a chill request, or somewhere else) from that day in the Calendar.
- Request to chill on any day, and opt in with one tap.
- Export an `.ics` file to add dates to your own calendar.

**Board**
- Messages with pins and emoji reactions.
- An Ideas tab where anyone can add, edit, and vote on activities. The ideas feed the plan chips on Home.

**Homies**
- Tap a person to see their profile: birthday, favorite color, snack, drink, custom facts, favorite group memory, and weekly work schedule.
- Badges show how many times someone has hosted and given ride shares. There is no leaderboard.
- Upcoming birthdays and favorite memories are collected on the main Homies page.

**Rides**
- Request a ride to the hangout, home from it, or both. Anyone else can claim it.
- Rides for other events show up under **Other rides** on Home so drivers see them.

## How it works

- One file: `index.html`. Plain HTML, CSS, and JavaScript. No framework, no build.
- Your device keeps a local copy of everything, so the app still opens when you are offline.
- With Supabase connected, changes sync between everyone's phones. The app checks for updates every 8 seconds and when you return to it.
- Sync is per item (each note, ride, post, and so on), so two people editing different things never overwrite each other. If two people edit the exact same item at the same moment, the last save wins.
- Without Supabase keys, the app runs on one device only.

## Setup

### 1. Create the Supabase backend

1. Create a free account and project at [supabase.com](https://supabase.com).
2. Open **SQL Editor**, click **New query**, paste in all of `supabase-setup.sql`, and click **Run**. It is safe to run more than once.
3. Open the **Connect** dialog on your project to find the **Project URL**, then go to **Project Settings > API Keys** and copy the **publishable key**. Never use a key labeled "secret".

### 2. Add your keys

In `index.html`, find this line near the top of the script:

```js
const CFG={url:'',key:''};
```

Paste your Project URL and publishable key between the quotes:

```js
const CFG={url:'https://yourproject.supabase.co',key:'sb_publishable_xxxxx'};
```

### 3. Publish with GitHub Pages

1. Put `index.html` at the top level of the repo.
2. In the repo, go to **Settings > Pages**. Set the source to **Deploy from a branch**, choose your main branch and the **/ (root)** folder, and save.
3. After a minute or two, GitHub shows your site address.

### 4. Start your group

1. Open the site on your phone. A join window appears.
2. Make up a group code only your group knows (at least 6 characters) and tap **Join**. The first person to use a new code creates the group.
3. In **Settings**, tap **Copy invite link** and send it to everyone. Opening the link joins them automatically.
4. Each person picks their name the first time they open the app.

Optional: use **Clear sample data** in Settings to remove the demo homies before you start.

## Security and privacy

- The group code is the only thing protecting your data. Use a real phrase, not something guessable, and only share it with people you want in the group.
- Anyone who has the code can read and change everything in the group. The app is built on trust, not permissions.
- The database table is locked. The app can only reach it through two functions that both require the group code, so one group cannot browse another group's rows.
- The publishable key in `index.html` is meant to be public. Do not put a secret key in the file.
- Data is stored in your own Supabase project, which you control.
- "Clear sample data" and "Reset to sample" in Settings change data for everyone in the group.

## Known limits

- Sync is not instant. Updates arrive within about 8 seconds.
- The `.ics` export is a one-time snapshot. Export again after plans change. It does not sync live with Apple, Google, or Outlook calendars, and it does not include work schedules.
- Work schedules are a weekly pattern. For one-off changes, use a note or "I'm busy".
- Removing the group code from your phone ("Leave group" in Settings) stops syncing but keeps a local copy of the data.

## Files

| File | Purpose |
| --- | --- |
| `index.html` | The whole app |
| `supabase-setup.sql` | One-time database setup for Supabase |
| `README.md` | This file |

## Tech

HTML, CSS, vanilla JavaScript, and Supabase (Postgres) accessed over plain REST calls. No dependencies to install.
