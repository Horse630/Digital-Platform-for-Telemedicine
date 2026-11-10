"""Build the second progress report and the test-case PDF.

Run from the Flutter project root:
  python tools/build_progress_docs.py
"""

from pathlib import Path

from docx import Document
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Inches, Pt
from PIL import Image, ImageDraw, ImageFont
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT
FLOW = OUT / "progress_flowchart.png"
ER = OUT / "progress_er.png"


def font(size):
    for name in ("arial.ttf", "segoeui.ttf", "calibri.ttf"):
        path = Path("C:/Windows/Fonts") / name
        if path.exists():
            return ImageFont.truetype(str(path), size)
    return ImageFont.load_default()


def box(draw, xy, text, fill, fnt):
    draw.rounded_rectangle(xy, radius=12, fill=fill, outline=(15, 118, 110), width=2)
    x1, y1, x2, y2 = xy
    # Center each line.
    lines = text.split("\n")
    line_h = 22
    total = line_h * len(lines)
    y = y1 + (y2 - y1 - total) / 2
    for line in lines:
        w = draw.textlength(line, font=fnt)
        draw.text(((x1 + x2 - w) / 2, y), line, fill=(20, 30, 30), font=fnt)
        y += line_h


def arrow(draw, start, end):
    draw.line([start, end], fill=(15, 118, 110), width=3)
    sx, sy = start
    ex, ey = end
    if abs(ex - sx) >= abs(ey - sy):
        sign = 1 if ex >= sx else -1
        head = [(ex, ey), (ex - 12 * sign, ey - 7), (ex - 12 * sign, ey + 7)]
    else:
        sign = 1 if ey >= sy else -1
        head = [(ex, ey), (ex - 7, ey - 12 * sign), (ex + 7, ey - 12 * sign)]
    draw.polygon(head, fill=(15, 118, 110))


def draw_flowchart():
    image = Image.new("RGB", (1400, 980), (247, 247, 247))
    draw = ImageDraw.Draw(image)
    title = font(28)
    body = font(18)
    draw.text((40, 24), "Visit, meeting, and medicine flow", fill=(15, 118, 110), font=title)
    steps = [
        (80, 90, "1. Patient chooses\nan open time"),
        (520, 90, "2. Patient writes\na short reason"),
        (960, 90, "3. Confirmation page\nbefore anything is saved"),
        (520, 280, "4. Booking is saved\nPending fee HKD 0"),
        (80, 470, "5. Doctor hosts\ntoday's visit"),
        (520, 470, "6. Patient sees it at once\nJoin stays off until 10 min"),
        (960, 470, "7. Waiting room,\nthen the doctor lets them in"),
        (80, 700, "8. Doctor marks the visit\ncompleted and writes a note"),
        (520, 700, "9. Stomach-medicine warning\nif the note names one"),
        (960, 700, "10. Patient can rate\nthe completed visit"),
    ]
    for x, y, text in steps:
        box(draw, (x, y, x + 360, y + 120), text, (255, 255, 255), body)
    arrow(draw, (440, 150), (520, 150))
    arrow(draw, (880, 150), (960, 150))
    arrow(draw, (1140, 210), (700, 280))
    arrow(draw, (700, 400), (260, 470))
    arrow(draw, (440, 530), (520, 530))
    arrow(draw, (880, 530), (960, 530))
    arrow(draw, (260, 590), (260, 700))
    arrow(draw, (440, 760), (520, 760))
    arrow(draw, (880, 760), (960, 760))
    image.save(FLOW)


def entity(draw, xy, title, lines, fnt, small):
    x1, y1, x2, y2 = xy
    draw.rectangle(xy, fill=(255, 255, 255), outline=(15, 118, 110), width=2)
    draw.rectangle((x1, y1, x2, y1 + 36), fill=(15, 118, 110))
    tw = draw.textlength(title, font=fnt)
    draw.text(((x1 + x2 - tw) / 2, y1 + 6), title, fill=(255, 255, 255), font=fnt)
    y = y1 + 46
    for line in lines:
        draw.text((x1 + 12, y), line, fill=(30, 40, 40), font=small)
        y += 22


def draw_er():
    image = Image.new("RGB", (1500, 900), (247, 247, 247))
    draw = ImageDraw.Draw(image)
    title = font(28)
    head = font(18)
    small = font(16)
    draw.text((40, 20), "Main data used by the running app", fill=(15, 118, 110), font=title)
    entity(draw, (40, 80, 340, 280), "User", ["role", "ratingSum, ratingCount", "deliveryAddress", "meetingRoomCode"], head, small)
    entity(draw, (420, 80, 760, 300), "Appointment", ["status", "reason, visitNote", "patientRating", "scheduledAt"], head, small)
    entity(draw, (840, 80, 1140, 250), "Consultation", ["status live or ended", "channelName", "waiting, admitted"], head, small)
    entity(draw, (1180, 80, 1460, 250), "Payment", ["amount HKD 0", "status pending", "provider demo"], head, small)
    entity(draw, (40, 460, 340, 640), "Delivery", ["medicationName", "status", "destination"], head, small)
    entity(draw, (420, 460, 760, 640), "HealthReading", ["metric", "value, unit", "recordedAt"], head, small)
    entity(draw, (840, 460, 1140, 640), "SickLeave", ["read only", "one per visit"], head, small)
    entity(draw, (1180, 460, 1460, 640), "Discussion", ["title, body", "doctor replies"], head, small)
    link = font(15)
    draw.text((300, 330), "doctor or patient  1 ---- *", fill=(15, 118, 110), font=link)
    draw.text((760, 150), "1 ---- 0..1", fill=(15, 118, 110), font=link)
    draw.text((1120, 150), "1 ---- *", fill=(15, 118, 110), font=link)
    draw.text((250, 400), "appointment 1 ---- * delivery", fill=(15, 118, 110), font=link)
    draw.text((360, 700), "patient 1 ---- * readings", fill=(15, 118, 110), font=link)
    draw.text((760, 700), "appointment 1 ---- 0..1 certificate", fill=(15, 118, 110), font=link)
    image.save(ER)


def add_heading(doc, text):
    doc.add_heading(text, level=1)


def add_para(doc, text):
    paragraph = doc.add_paragraph(text)
    paragraph.paragraph_format.space_after = Pt(8)
    for run in paragraph.runs:
        run.font.size = Pt(12)
        run.font.name = "Calibri"


def build_report():
    doc = Document()
    section = doc.sections[0]
    section.top_margin = Inches(0.8)
    section.bottom_margin = Inches(0.8)
    section.left_margin = Inches(0.9)
    section.right_margin = Inches(0.9)

    cover = doc.add_paragraph()
    cover.alignment = WD_ALIGN_PARAGRAPH.CENTER
    for line in [
        "Hong Kong Baptist University",
        "Department of Computer Science",
        "COMP4878-9 Innovative Computing Project I",
        "",
        "Project: Digital Platform for Telemedicine",
        "Supervisor: Prof. LEUNG, Yiu Wing",
        "Student Name: Ma Chun Kit",
        "Student Number: 23230215",
        "",
        "Second Progress Report",
        "10 November 2026",
    ]:
        run = cover.add_run(line + "\n")
        run.bold = line in {"Second Progress Report", "Hong Kong Baptist University"}
        run.font.size = Pt(16 if line == "Second Progress Report" else 12)
        run.font.name = "Calibri"

    add_heading(doc, "Abstract")
    add_para(
        doc,
        "This report records the work finished after the first progress report. The client is a Flutter app. It talks only to a Node.js API, and that API is the only part that talks to MongoDB Atlas. The build now covers booking with a confirmation page, meetings with a waiting room, sick-leave certificates, a Hong Kong map, medicine-order status, visit notes, a course-demo notice, typed health readings, and a fixed app guide. Live video, PayPal, a courier GPS feed, the HKBU GenAI API, and a wearable library are not connected. On 10 November 2026 the automated test command flutter test finished with 27 passed.",
    )
    add_para(
        doc,
        "Note on AI usage: Cursor was used to draft this report from the current source and the passing test run. The diagrams were drawn for this report. The student should read the report before submitting it.",
    )

    add_heading(doc, "Project Background")
    add_para(
        doc,
        "The project is a course information system for a remote clinic. A patient should be able to book a visit, meet the doctor, receive a certificate, and follow a medicine order without leaving the same app. The first report chose Flutter for the client and MongoDB for storage, and it listed several outside services. This second report keeps that client and database, and it records which of those services are now replaced by a local course-demo behaviour.",
    )

    add_heading(doc, "The objectives of your project")
    add_para(
        doc,
        "The objective is still one system for the visit from booking through follow-up. The patient books a doctor, joins a meeting, reads a sick-leave certificate, and sees whether medicine is preparing, in transit, or delivered. The doctor publishes times, hosts the meeting, writes the certificate and the visit note, and updates the medicine order. An admin can read records and does not change them.",
    )

    add_heading(doc, "Proposed system solution or changes made to your previously proposed solution")
    add_para(
        doc,
        "The running shape is Flutter to HTTP, then Node.js and Express to MongoDB Atlas, database name telemedicine. The phone never opens the database. Language, colour, font size, and easy mode stay on the device.",
    )
    add_para(
        doc,
        "Changes from the first report: sick-leave files use the pdf package on the device instead of Syncfusion. The map uses OpenFreeMap vector tiles and a saved copy of public clinic and hospital data, instead of the Hong Kong Vector Map API. The meeting room keeps a room number and a waiting room, and it does not send the camera. Payment is a pending row of HKD 0 with provider demo, and PayPal is not called. The app guide uses three fixed answers, and the HKBU GenAI API is not called. Health readings are numbers the patient types, and the health package is not installed.",
    )
    add_para(doc, "Figure 1 shows the path from an open time to a completed visit.")
    doc.add_picture(str(FLOW), width=Inches(6.4))
    doc.add_paragraph("Figure 1. Flow from booking to a completed visit.").alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_para(doc, "Figure 2 shows the main records and how they link. It is not a SQL schema. MongoDB stores these as collections.")
    doc.add_picture(str(ER), width=Inches(6.4))
    doc.add_paragraph("Figure 2. Entity relationship of the records used by the app.").alignment = WD_ALIGN_PARAGRAPH.CENTER

    add_heading(doc, "Proposed schedule & what you have achieved so far")
    add_para(
        doc,
        "The first report planned core booking and certificates in November, video and map APIs in December, and the chatbot and wearable work in February. By 10 November 2026 the following are in the app and covered by the plan file.",
    )
    for item in [
        "Sign-in, sign-up, three roles, and a course-demo checkbox that must be ticked before an account is created.",
        "Appointments: a doctor publishes a future time, a patient books it only after a confirmation page, and a cancel at least one day ahead is described as free. No money is taken.",
        "Meetings: the doctor hosts today's visit. The patient sees that hosted meeting immediately. The join button stays off until 10 minutes before the booked time. The room does not send a live picture.",
        "A doctor can mark a booked visit completed, write a visit note, and the patient can read it. If the note names aspirin, ibuprofen, naproxen, or diclofenac, the card warns that a stomach medicine should be paired with it. The patient can rate a completed visit once.",
        "Sick-leave certificates, direct messages, and the public discussion board.",
        "A Hong Kong map pinned at Hong Kong Baptist University, Kowloon Tong, plus public clinics and hospitals. A doctor can create a medicine order for a booked visit and move its status. The patient's typed address is the destination text. It is not drawn as a moving van.",
        "Settings for language, dark mode, colour, font size, easy mode, and action notices. An action notice is a line stored on the device after a booking. It is not email, SMS, or a push message.",
        "An app guide with fixed answers, and a health screen where a patient types a heart rate, step count, or blood oxygen.",
    ]:
        doc.add_paragraph(item, style="List Bullet")

    add_heading(doc, "Problems (if any) you are having with the project")
    add_para(
        doc,
        "The outside services named in the first report need accounts or keys that this course build does not have. Because of that, live video, PayPal, courier GPS, the HKBU assistant, a wearable, and a password-reset email are not connected. The demo sign-in buttons are still on the login screen so the three sample accounts can be shown. Formal legal terms are not written; the sign-up checkbox is only a course-demo notice. A new API route does nothing until the Node process is started again from the backend folder.",
    )

    add_heading(doc, "What activities you are currently engaging in")
    add_para(
        doc,
        "The current work is to keep the client, the API, and plan.md describing the same behaviour, and to test that behaviour. The automated suite was run on 10 November 2026 and reported 27 passed. The separate test-case PDF lists each case. The next useful work, once a vendor is chosen, is one live-video SDK and one real payment or courier account. Until then the local status fields are the course-demo stand-in.",
    )

    add_heading(doc, "Reference")
    for ref in [
        "[1] Flutter, https://flutter.dev/ (accessed 10 Nov. 2026).",
        "[2] Dart, https://dart.dev/ (accessed 10 Nov. 2026).",
        "[3] MongoDB, https://www.mongodb.com (accessed 10 Nov. 2026).",
        "[4] Express, https://expressjs.com/ (accessed 10 Nov. 2026).",
        "[5] OpenFreeMap, https://openfreemap.org/ (accessed 10 Nov. 2026).",
    ]:
        add_para(doc, ref)

    doc.save(OUT / "MA_Chun_Kit_Second_Progress_Report_23230215.docx")


def build_pdf():
    styles = getSampleStyleSheet()
    styles["Normal"].fontSize = 8
    styles["Normal"].leading = 10
    story = [
        Paragraph("COMP4878-9 Digital Platform for Telemedicine", styles["Title"]),
        Paragraph("Test cases — Ma Chun Kit (23230215) — 10 November 2026", styles["Heading2"]),
        Paragraph(
            "The Result column Pass means flutter test completed that case on 10 November 2026 (27 passed, 0 failed). A case marked Designed was checked in the source and was not clicked against a live API in this run. Start the API with npm start from the backend folder before a live click-through.",
            styles["Normal"],
        ),
        Spacer(1, 4 * mm),
    ]
    header = ["ID", "Case", "Steps", "Expected", "Result"]
    rows = [
        ["TC-01", "Startup", "Open the app and wait for the startup animation.", "The sign-in screen appears.", "Pass"],
        ["TC-02", "Welcome", "Sign in with a valid account.", "A welcome with the username appears, then home.", "Pass"],
        ["TC-03", "Login language", "On the sign-in card, choose Traditional Chinese.", "The sign-in label becomes 登入.", "Pass"],
        ["TC-04", "Empty sign-in", "Submit the sign-in form with both fields empty.", "The form asks for both fields.", "Pass"],
        ["TC-05", "Wrong password", "Submit a username with the wrong password.", "The person stays on the sign-in screen.", "Pass"],
        ["TC-06", "Admin path", "Sign in as admin, open a tab, then log out.", "The dashboard opens and logout returns to sign-in.", "Pass"],
        ["TC-07", "Payment tile", "On home, open Payment.", "The tile says the service is not available yet.", "Pass"],
        ["TC-08", "Easy mode", "Turn on easy mode and look at home and the tab bar.", "Four large actions remain. Meetings is not a tab.", "Pass"],
        ["TC-09", "Wide layout", "Use a window at least 840 px wide.", "The side rail is used.", "Pass"],
        ["TC-10", "Map pin", "Open the delivery map widget.", "The headquarters pin is Hong Kong Baptist University.", "Pass"],
        ["TC-11", "Facilities file", "Load the saved clinic and hospital file.", "77 clinics have hours and 44 hospitals are listed.", "Pass"],
        ["TC-12", "Sign-up", "Create an account, tick the course notice, and use a new username.", "Home opens. A taken username is rejected.", "Pass"],
        ["TC-13", "Settings", "Save a description, switch dark mode, and add an allergy.", "The values stay. A mismatched password is rejected.", "Pass"],
        ["TC-14", "Appointment filters", "Search, filter by doctor type, and sort the open times.", "Matching rows remain and the order follows the sort.", "Pass"],
        ["TC-15", "Hosted meeting", "Parse a live meeting whose canEnter flag is false.", "The meeting stays on the list and cannot be entered yet.", "Pass"],
        ["TC-16", "Visit warning", "Read a completed visit whose note names ibuprofen.", "medicineWarning is true and the doctor rating is kept.", "Pass"],
        ["TC-17", "Confirm booking", "Patient writes a reason, then opens the confirmation page.", "The visit is saved only after Confirm booking. A pending HKD 0 payment row is written. PayPal is not called.", "Designed"],
        ["TC-18", "Free cancel", "Patient cancels a visit that is at least one day away.", "The dialog says the cancellation is free. The time opens again.", "Designed"],
        ["TC-19", "Complete visit", "Doctor marks a booked visit completed and writes a note.", "The patient sees status completed and the note.", "Designed"],
        ["TC-20", "Rate visit", "Patient chooses 1 to 5 stars on a completed visit.", "The rating is stored once. A second rating is rejected.", "Designed"],
        ["TC-21", "Medicine order", "Doctor creates an order, then advances it twice.", "Status moves preparing, in transit, delivered. Destination is the saved address.", "Designed"],
        ["TC-22", "Health reading", "Patient types a heart rate and saves it.", "The new reading is listed. A wearable is not read.", "Designed"],
        ["TC-23", "App guide", "Open the guide tile.", "Three fixed answers appear. The HKBU API is not called.", "Designed"],
    ]
    data = [header]
    wrapped = []
    for row in rows:
        wrapped.append([Paragraph(cell, styles["Normal"]) for cell in row])
    data = [[Paragraph(cell, styles["Normal"]) for cell in header]] + wrapped
    table = Table(data, colWidths=[16 * mm, 28 * mm, 52 * mm, 58 * mm, 22 * mm])
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0F766E")),
                ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
                ("GRID", (0, 0), (-1, -1), 0.3, colors.HexColor("#0F766E")),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#F7F7F7")),
                ("LEFTPADDING", (0, 0), (-1, -1), 3),
                ("RIGHTPADDING", (0, 0), (-1, -1), 3),
                ("TOPPADDING", (0, 0), (-1, -1), 3),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
            ]
        )
    )
    story.append(table)
    story.append(Spacer(1, 6 * mm))
    story.append(
        Paragraph(
            "Backend syntax for the appointment, meeting, delivery, and health-reading route files was checked with node --check on the same day. That check does not connect to MongoDB.",
            styles["Normal"],
        )
    )
    pdf = SimpleDocTemplate(
        str(OUT / "MA_Chun_Kit_Test_Cases_23230215.pdf"),
        pagesize=A4,
        leftMargin=12 * mm,
        rightMargin=12 * mm,
        topMargin=12 * mm,
        bottomMargin=12 * mm,
    )
    pdf.build(story)


if __name__ == "__main__":
    draw_flowchart()
    draw_er()
    build_report()
    build_pdf()
    print("wrote report and test-case pdf")
