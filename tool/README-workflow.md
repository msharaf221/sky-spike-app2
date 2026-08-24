# تعديل الـ GitHub Actions (خطوة يدوية مطلوبة)

الوكيل (bot) الذي يدفع هذا الفرع لا يملك صلاحية `workflows`، لذلك
GitHub يرفض أي تعديل على `.github/workflows/` قادم منه. لهذا السبب
تعديل الـ workflow **غير مضمّن** في الـ commit، ومحفوظ هنا بدلاً من ذلك.

## المطلوب منك

انسخ الملف الجاهز فوق الملف الحالي:

```bash
cp tool/android-workflow.proposed.yml .github/workflows/android.yml
git add .github/workflows/android.yml
git commit -m "CI: generate launcher icons from the Sky Spike logo"
git push origin arena/01a03591-sky-spike-app2
```

أو طبّق الـ patch:

```bash
git apply tool/android-workflow.patch
```

## ما الذي يضيفه التعديل

| الخطوة | الغرض |
| --- | --- |
| `pull_request` trigger | يبني الـ APK على الـ PR وليس بعد الدمج فقط |
| `Install Pillow` | مكتبة معالجة الصور المطلوبة لتوليد الأيقونات |
| `Generate Launcher Icons from Logo` | ينفّذ `tool/generate_launcher_icons.py` لتوليد أيقونة التطبيق من اللوجو |
| `Set Application Name` | يضبط اسم التطبيق تحت الأيقونة إلى `Sky Spike` |

الترتيب مهم: خطوة توليد الأيقونات تأتي **بعد** `flutter create`، لأن
`flutter create` يعيد إنشاء أيقونات Flutter الافتراضية وسيمسح أيقوناتنا
لو نُفّذت قبلها.

خطوة توليد الأيقونات وحدها تعمل محلياً أيضاً:

```bash
python3 -m pip install pillow
python3 tool/generate_launcher_icons.py
```

اسم الـ artifact يبقى `SkySpike-App` كما هو.
