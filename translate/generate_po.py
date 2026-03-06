#!/usr/bin/env python3
"""Generate .po translation files for Task Manager Colors plasmoid."""
import os
import datetime

DIR = os.path.dirname(os.path.abspath(__file__))

TRANSLATIONS = {
    "fr": {
        "language": "French",
        "team": "French <fr@li.org>",
        "strings": {
            "General": "Général",
            "General:": "Général :",
            "Enable color overlays": "Activer les surcouches de couleur",
            "Color mode:": "Mode de couleur :",
            "Frame (all sides)": "Cadre (tous les côtés)",
            "Top line": "Ligne du haut",
            "Bottom line": "Ligne du bas",
            "Left line": "Ligne gauche",
            "Right line": "Ligne droite",
            "Top + Bottom": "Haut + Bas",
            "Left + Right": "Gauche + Droite",
            "Background": "Arrière-plan",
            "Background + Frame": "Arrière-plan + Cadre",
            "Diagonal \\": "Diagonale \\",
            "Diagonal /": "Diagonale /",
            "Diagonal ✕": "Diagonale ✕",
            "Thickness:": "Épaisseur :",
            "Auto": "Auto",
            "Corner radius:": "Rayon des coins :",
            "Background opacity:": "Opacité de l'arrière-plan :",
            "Pinned apps:": "Applications épinglées :",
            "Always colored": "Toujours colorées",
            "Only when running": "Uniquement en cours d'exécution",
            "Focus:": "Focus :",
            "Keep color visible on focused task": "Garder la couleur visible sur la tâche active",
            "Colors:": "Couleurs :",
            "%1 application(s) configured": "%1 application(s) configurée(s)",
            "No colors configured": "Aucune couleur configurée",
            "Click again to confirm": "Cliquer à nouveau pour confirmer",
            "Reset all colors": "Réinitialiser toutes les couleurs",
            "Task Manager Colors": "Couleurs du gestionnaire de tâches",
            "Applications": "Applications",
            "Windows (%1)": "Fenêtres (%1)",
            "Settings": "Paramètres",
            "About": "À propos",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Attribuer une couleur persistante à chaque application. La couleur s'applique à toutes les fenêtres de cette application.",
            "No tasks detected — open some windows to assign colors.":
                "Aucune tâche détectée — ouvrez des fenêtres pour attribuer des couleurs.",
            "(pinned)": "(épinglée)",
            "Remove color": "Supprimer la couleur",
            "Color for: %1": "Couleur pour : %1",
            "Pick a color": "Choisir une couleur",
            "Cancel": "Annuler",
            "Used:": "Utilisées :",
            "Extracting…": "Extraction…",
            "Auto (from icon)": "Auto (depuis l'icône)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Remplacer temporairement la couleur d'une fenêtre spécifique. Les remplacements sont perdus à la fermeture de la fenêtre.",
            "No windows detected — open some windows to use per-window overrides.":
                "Aucune fenêtre détectée — ouvrez des fenêtres pour utiliser les remplacements par fenêtre.",
            "Reset to app color": "Réinitialiser à la couleur de l'application",
            "Window color override": "Remplacement de la couleur de fenêtre",
            "Configure how colors are displayed on task manager entries.":
                "Configurer l'affichage des couleurs sur les entrées du gestionnaire de tâches.",
            "Mode": "Mode",
            "How the color overlay is rendered on each task.":
                "Comment la surcouche de couleur est rendue sur chaque tâche.",
            "Thickness": "Épaisseur",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Épaisseur du bord/de la ligne. Auto lit les marges SVG du thème.",
            "Opacity": "Opacité",
            "Background fill intensity.": "Intensité du remplissage de l'arrière-plan.",
            "Corners": "Coins",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Arrondi des coins. Auto correspond au thème actuel. Max = cercle parfait.",
            "Behavior": "Comportement",
            "Show color on pinned favorites even when no window is open.":
                "Afficher la couleur sur les favoris épinglés même quand aucune fenêtre n'est ouverte.",
            "Keep color on focused task": "Garder la couleur sur la tâche active",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "La surcouche reste visible au-dessus de la surbrillance de focus Plasma (80% arrière-plan + ligne d'accent en haut).",
            "Version %1": "Version %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Surcouches de couleur par application et par fenêtre pour le gestionnaire de tâches Plasma.",
            "Author": "Auteur",
            "Disabled — toggle switch above to enable": "Désactivé — activer l'interrupteur ci-dessus",
            "Must be placed in a panel": "Doit être placé dans un panneau",
            "Disabled": "Désactivé",
            "%1 application(s) colored": "%1 application(s) colorée(s)",
            "Click to assign colors": "Cliquer pour attribuer des couleurs",
        },
    },
    "de": {
        "language": "German",
        "team": "German <de@li.org>",
        "strings": {
            "General": "Allgemein",
            "General:": "Allgemein:",
            "Enable color overlays": "Farbüberlagerungen aktivieren",
            "Color mode:": "Farbmodus:",
            "Frame (all sides)": "Rahmen (alle Seiten)",
            "Top line": "Obere Linie",
            "Bottom line": "Untere Linie",
            "Left line": "Linke Linie",
            "Right line": "Rechte Linie",
            "Top + Bottom": "Oben + Unten",
            "Left + Right": "Links + Rechts",
            "Background": "Hintergrund",
            "Background + Frame": "Hintergrund + Rahmen",
            "Diagonal \\": "Diagonal \\",
            "Diagonal /": "Diagonal /",
            "Diagonal ✕": "Diagonal ✕",
            "Thickness:": "Stärke:",
            "Auto": "Auto",
            "Corner radius:": "Eckenradius:",
            "Background opacity:": "Hintergrund-Deckkraft:",
            "Pinned apps:": "Angeheftete Apps:",
            "Always colored": "Immer eingefärbt",
            "Only when running": "Nur wenn aktiv",
            "Focus:": "Fokus:",
            "Keep color visible on focused task": "Farbe bei fokussierter Aufgabe beibehalten",
            "Colors:": "Farben:",
            "%1 application(s) configured": "%1 Anwendung(en) konfiguriert",
            "No colors configured": "Keine Farben konfiguriert",
            "Click again to confirm": "Zur Bestätigung erneut klicken",
            "Reset all colors": "Alle Farben zurücksetzen",
            "Task Manager Colors": "Fensterleiste Farben",
            "Applications": "Anwendungen",
            "Windows (%1)": "Fenster (%1)",
            "Settings": "Einstellungen",
            "About": "Über",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Weisen Sie jeder Anwendung eine dauerhafte Farbe zu. Die Farbe gilt für alle Fenster dieser Anwendung.",
            "No tasks detected — open some windows to assign colors.":
                "Keine Aufgaben erkannt — öffnen Sie Fenster, um Farben zuzuweisen.",
            "(pinned)": "(angeheftet)",
            "Remove color": "Farbe entfernen",
            "Color for: %1": "Farbe für: %1",
            "Pick a color": "Farbe auswählen",
            "Cancel": "Abbrechen",
            "Used:": "Verwendet:",
            "Extracting…": "Extrahiere…",
            "Auto (from icon)": "Auto (aus Symbol)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Farbe eines bestimmten Fensters vorübergehend überschreiben. Überschreibungen gehen beim Schließen des Fensters verloren.",
            "No windows detected — open some windows to use per-window overrides.":
                "Keine Fenster erkannt — öffnen Sie Fenster für fensterspezifische Überschreibungen.",
            "Reset to app color": "Auf App-Farbe zurücksetzen",
            "Window color override": "Fensterfarbe überschreiben",
            "Configure how colors are displayed on task manager entries.":
                "Konfigurieren Sie, wie Farben auf den Einträgen der Fensterleiste angezeigt werden.",
            "Mode": "Modus",
            "How the color overlay is rendered on each task.":
                "Wie die Farbüberlagerung auf jeder Aufgabe gerendert wird.",
            "Thickness": "Stärke",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Rahmen-/Linienstärke. Auto liest aus den SVG-Rändern des Designs.",
            "Opacity": "Deckkraft",
            "Background fill intensity.": "Hintergrundfüllungsintensität.",
            "Corners": "Ecken",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Eckenabrundung. Auto passt zum aktuellen Design. Max = perfekter Kreis.",
            "Behavior": "Verhalten",
            "Show color on pinned favorites even when no window is open.":
                "Farbe auf angehefteten Favoriten anzeigen, auch wenn kein Fenster geöffnet ist.",
            "Keep color on focused task": "Farbe bei fokussierter Aufgabe beibehalten",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Überlagerung bleibt über Plasmas Fokus-Hervorhebung sichtbar (80% Hintergrund + obere Akzentlinie).",
            "Version %1": "Version %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Anwendungs- und fensterspezifische Farbüberlagerungen für die Plasma-Fensterleiste.",
            "Author": "Autor",
            "Disabled — toggle switch above to enable": "Deaktiviert — Schalter oben aktivieren",
            "Must be placed in a panel": "Muss in einer Leiste platziert werden",
            "Disabled": "Deaktiviert",
            "%1 application(s) colored": "%1 Anwendung(en) eingefärbt",
            "Click to assign colors": "Klicken, um Farben zuzuweisen",
        },
    },
    "es": {
        "language": "Spanish",
        "team": "Spanish <es@li.org>",
        "strings": {
            "General": "General",
            "General:": "General:",
            "Enable color overlays": "Activar superposiciones de color",
            "Color mode:": "Modo de color:",
            "Frame (all sides)": "Marco (todos los lados)",
            "Top line": "Línea superior",
            "Bottom line": "Línea inferior",
            "Left line": "Línea izquierda",
            "Right line": "Línea derecha",
            "Top + Bottom": "Superior + Inferior",
            "Left + Right": "Izquierda + Derecha",
            "Background": "Fondo",
            "Background + Frame": "Fondo + Marco",
            "Diagonal \\": "Diagonal \\",
            "Diagonal /": "Diagonal /",
            "Diagonal ✕": "Diagonal ✕",
            "Thickness:": "Grosor:",
            "Auto": "Auto",
            "Corner radius:": "Radio de esquinas:",
            "Background opacity:": "Opacidad del fondo:",
            "Pinned apps:": "Apps fijadas:",
            "Always colored": "Siempre coloreadas",
            "Only when running": "Solo en ejecución",
            "Focus:": "Foco:",
            "Keep color visible on focused task": "Mantener color visible en tarea enfocada",
            "Colors:": "Colores:",
            "%1 application(s) configured": "%1 aplicación(es) configurada(s)",
            "No colors configured": "Sin colores configurados",
            "Click again to confirm": "Clic de nuevo para confirmar",
            "Reset all colors": "Restablecer todos los colores",
            "Task Manager Colors": "Colores del gestor de tareas",
            "Applications": "Aplicaciones",
            "Windows (%1)": "Ventanas (%1)",
            "Settings": "Ajustes",
            "About": "Acerca de",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Asignar un color persistente a cada aplicación. El color se aplica a todas las ventanas de esa aplicación.",
            "No tasks detected — open some windows to assign colors.":
                "No se detectaron tareas — abra ventanas para asignar colores.",
            "(pinned)": "(fijada)",
            "Remove color": "Eliminar color",
            "Color for: %1": "Color para: %1",
            "Pick a color": "Elegir un color",
            "Cancel": "Cancelar",
            "Used:": "Usados:",
            "Extracting…": "Extrayendo…",
            "Auto (from icon)": "Auto (desde icono)",
            "OK": "Aceptar",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Anular temporalmente el color de una ventana específica. Las anulaciones se pierden al cerrar la ventana.",
            "No windows detected — open some windows to use per-window overrides.":
                "No se detectaron ventanas — abra ventanas para usar anulaciones por ventana.",
            "Reset to app color": "Restablecer al color de la aplicación",
            "Window color override": "Anulación de color de ventana",
            "Configure how colors are displayed on task manager entries.":
                "Configurar cómo se muestran los colores en las entradas del gestor de tareas.",
            "Mode": "Modo",
            "How the color overlay is rendered on each task.":
                "Cómo se renderiza la superposición de color en cada tarea.",
            "Thickness": "Grosor",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Grosor del borde/línea. Auto lee los márgenes SVG del tema.",
            "Opacity": "Opacidad",
            "Background fill intensity.": "Intensidad de relleno del fondo.",
            "Corners": "Esquinas",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Redondeo de esquinas. Auto coincide con el tema actual. Máx = círculo perfecto.",
            "Behavior": "Comportamiento",
            "Show color on pinned favorites even when no window is open.":
                "Mostrar color en favoritos fijados incluso sin ventanas abiertas.",
            "Keep color on focused task": "Mantener color en tarea enfocada",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "La superposición permanece visible sobre el resaltado de foco de Plasma (80% fondo + línea de acento superior).",
            "Version %1": "Versión %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Superposiciones de color por aplicación y por ventana para el gestor de tareas de Plasma.",
            "Author": "Autor",
            "Disabled — toggle switch above to enable": "Desactivado — active el interruptor de arriba",
            "Must be placed in a panel": "Debe colocarse en un panel",
            "Disabled": "Desactivado",
            "%1 application(s) colored": "%1 aplicación(es) coloreada(s)",
            "Click to assign colors": "Clic para asignar colores",
        },
    },
    "pt_BR": {
        "language": "Brazilian Portuguese",
        "team": "Brazilian Portuguese <pt_BR@li.org>",
        "strings": {
            "General": "Geral",
            "General:": "Geral:",
            "Enable color overlays": "Ativar sobreposições de cores",
            "Color mode:": "Modo de cor:",
            "Frame (all sides)": "Moldura (todos os lados)",
            "Top line": "Linha superior",
            "Bottom line": "Linha inferior",
            "Left line": "Linha esquerda",
            "Right line": "Linha direita",
            "Top + Bottom": "Superior + Inferior",
            "Left + Right": "Esquerda + Direita",
            "Background": "Plano de fundo",
            "Background + Frame": "Plano de fundo + Moldura",
            "Diagonal \\": "Diagonal \\",
            "Diagonal /": "Diagonal /",
            "Diagonal ✕": "Diagonal ✕",
            "Thickness:": "Espessura:",
            "Auto": "Auto",
            "Corner radius:": "Raio dos cantos:",
            "Background opacity:": "Opacidade do plano de fundo:",
            "Pinned apps:": "Apps fixados:",
            "Always colored": "Sempre coloridos",
            "Only when running": "Apenas em execução",
            "Focus:": "Foco:",
            "Keep color visible on focused task": "Manter cor visível na tarefa em foco",
            "Colors:": "Cores:",
            "%1 application(s) configured": "%1 aplicativo(s) configurado(s)",
            "No colors configured": "Nenhuma cor configurada",
            "Click again to confirm": "Clique novamente para confirmar",
            "Reset all colors": "Redefinir todas as cores",
            "Task Manager Colors": "Cores do gerenciador de tarefas",
            "Applications": "Aplicativos",
            "Windows (%1)": "Janelas (%1)",
            "Settings": "Configurações",
            "About": "Sobre",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Atribuir uma cor persistente a cada aplicativo. A cor se aplica a todas as janelas desse aplicativo.",
            "No tasks detected — open some windows to assign colors.":
                "Nenhuma tarefa detectada — abra janelas para atribuir cores.",
            "(pinned)": "(fixado)",
            "Remove color": "Remover cor",
            "Color for: %1": "Cor para: %1",
            "Pick a color": "Escolher uma cor",
            "Cancel": "Cancelar",
            "Used:": "Usadas:",
            "Extracting…": "Extraindo…",
            "Auto (from icon)": "Auto (do ícone)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Substituir temporariamente a cor de uma janela específica. As substituições são perdidas ao fechar a janela.",
            "No windows detected — open some windows to use per-window overrides.":
                "Nenhuma janela detectada — abra janelas para usar substituições por janela.",
            "Reset to app color": "Redefinir para cor do aplicativo",
            "Window color override": "Substituição de cor da janela",
            "Configure how colors are displayed on task manager entries.":
                "Configurar como as cores são exibidas nas entradas do gerenciador de tarefas.",
            "Mode": "Modo",
            "How the color overlay is rendered on each task.":
                "Como a sobreposição de cor é renderizada em cada tarefa.",
            "Thickness": "Espessura",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Espessura da borda/linha. Auto lê as margens SVG do tema.",
            "Opacity": "Opacidade",
            "Background fill intensity.": "Intensidade do preenchimento do plano de fundo.",
            "Corners": "Cantos",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Arredondamento dos cantos. Auto corresponde ao tema atual. Máx = círculo perfeito.",
            "Behavior": "Comportamento",
            "Show color on pinned favorites even when no window is open.":
                "Mostrar cor em favoritos fixados mesmo sem janelas abertas.",
            "Keep color on focused task": "Manter cor na tarefa em foco",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "A sobreposição permanece visível acima do destaque de foco do Plasma (80% fundo + linha de acento superior).",
            "Version %1": "Versão %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Sobreposições de cor por aplicativo e por janela para o gerenciador de tarefas do Plasma.",
            "Author": "Autor",
            "Disabled — toggle switch above to enable": "Desativado — ative o interruptor acima",
            "Must be placed in a panel": "Deve ser colocado em um painel",
            "Disabled": "Desativado",
            "%1 application(s) colored": "%1 aplicativo(s) colorido(s)",
            "Click to assign colors": "Clique para atribuir cores",
        },
    },
    "ru": {
        "language": "Russian",
        "team": "Russian <ru@li.org>",
        "strings": {
            "General": "Общие",
            "General:": "Общие:",
            "Enable color overlays": "Включить цветные наложения",
            "Color mode:": "Режим цвета:",
            "Frame (all sides)": "Рамка (все стороны)",
            "Top line": "Верхняя линия",
            "Bottom line": "Нижняя линия",
            "Left line": "Левая линия",
            "Right line": "Правая линия",
            "Top + Bottom": "Верх + Низ",
            "Left + Right": "Лево + Право",
            "Background": "Фон",
            "Background + Frame": "Фон + Рамка",
            "Diagonal \\": "Диагональ \\",
            "Diagonal /": "Диагональ /",
            "Diagonal ✕": "Диагональ ✕",
            "Thickness:": "Толщина:",
            "Auto": "Авто",
            "Corner radius:": "Радиус углов:",
            "Background opacity:": "Непрозрачность фона:",
            "Pinned apps:": "Закреплённые приложения:",
            "Always colored": "Всегда окрашены",
            "Only when running": "Только при запуске",
            "Focus:": "Фокус:",
            "Keep color visible on focused task": "Сохранять цвет на активной задаче",
            "Colors:": "Цвета:",
            "%1 application(s) configured": "%1 приложение(й) настроено",
            "No colors configured": "Цвета не настроены",
            "Click again to confirm": "Нажмите ещё раз для подтверждения",
            "Reset all colors": "Сбросить все цвета",
            "Task Manager Colors": "Цвета панели задач",
            "Applications": "Приложения",
            "Windows (%1)": "Окна (%1)",
            "Settings": "Настройки",
            "About": "О программе",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Назначить постоянный цвет каждому приложению. Цвет применяется ко всем окнам этого приложения.",
            "No tasks detected — open some windows to assign colors.":
                "Задачи не обнаружены — откройте окна для назначения цветов.",
            "(pinned)": "(закреплено)",
            "Remove color": "Удалить цвет",
            "Color for: %1": "Цвет для: %1",
            "Pick a color": "Выбрать цвет",
            "Cancel": "Отмена",
            "Used:": "Используемые:",
            "Extracting…": "Извлечение…",
            "Auto (from icon)": "Авто (из значка)",
            "OK": "ОК",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Временно переопределить цвет конкретного окна. Переопределения теряются при закрытии окна.",
            "No windows detected — open some windows to use per-window overrides.":
                "Окна не обнаружены — откройте окна для использования переопределений по окнам.",
            "Reset to app color": "Сбросить на цвет приложения",
            "Window color override": "Переопределение цвета окна",
            "Configure how colors are displayed on task manager entries.":
                "Настроить отображение цветов на записях панели задач.",
            "Mode": "Режим",
            "How the color overlay is rendered on each task.":
                "Как цветное наложение отображается на каждой задаче.",
            "Thickness": "Толщина",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Толщина границы/линии. Авто читает из SVG-полей темы.",
            "Opacity": "Непрозрачность",
            "Background fill intensity.": "Интенсивность заливки фона.",
            "Corners": "Углы",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Скругление углов. Авто соответствует текущей теме. Макс = идеальный круг.",
            "Behavior": "Поведение",
            "Show color on pinned favorites even when no window is open.":
                "Показывать цвет на закреплённых избранных даже без открытых окон.",
            "Keep color on focused task": "Сохранять цвет на активной задаче",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Наложение остаётся видимым поверх подсветки фокуса Plasma (80% фон + верхняя акцентная линия).",
            "Version %1": "Версия %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Цветные наложения по приложениям и по окнам для панели задач Plasma.",
            "Author": "Автор",
            "Disabled — toggle switch above to enable": "Отключено — включите переключатель выше",
            "Must be placed in a panel": "Должен быть размещён на панели",
            "Disabled": "Отключено",
            "%1 application(s) colored": "%1 приложение(й) окрашено",
            "Click to assign colors": "Нажмите для назначения цветов",
        },
    },
    "zh_CN": {
        "language": "Chinese (Simplified)",
        "team": "Chinese (Simplified) <zh_CN@li.org>",
        "strings": {
            "General": "常规",
            "General:": "常规：",
            "Enable color overlays": "启用颜色叠加",
            "Color mode:": "颜色模式：",
            "Frame (all sides)": "边框（所有边）",
            "Top line": "顶部线条",
            "Bottom line": "底部线条",
            "Left line": "左侧线条",
            "Right line": "右侧线条",
            "Top + Bottom": "顶部 + 底部",
            "Left + Right": "左侧 + 右侧",
            "Background": "背景",
            "Background + Frame": "背景 + 边框",
            "Diagonal \\": "对角线 \\",
            "Diagonal /": "对角线 /",
            "Diagonal ✕": "对角线 ✕",
            "Thickness:": "厚度：",
            "Auto": "自动",
            "Corner radius:": "圆角半径：",
            "Background opacity:": "背景不透明度：",
            "Pinned apps:": "固定应用：",
            "Always colored": "始终着色",
            "Only when running": "仅在运行时",
            "Focus:": "焦点：",
            "Keep color visible on focused task": "在聚焦任务上保持颜色可见",
            "Colors:": "颜色：",
            "%1 application(s) configured": "已配置 %1 个应用",
            "No colors configured": "未配置颜色",
            "Click again to confirm": "再次点击确认",
            "Reset all colors": "重置所有颜色",
            "Task Manager Colors": "任务管理器颜色",
            "Applications": "应用程序",
            "Windows (%1)": "窗口 (%1)",
            "Settings": "设置",
            "About": "关于",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "为每个应用分配持久颜色。颜色适用于该应用的所有窗口。",
            "No tasks detected — open some windows to assign colors.":
                "未检测到任务——请打开窗口以分配颜色。",
            "(pinned)": "（固定）",
            "Remove color": "移除颜色",
            "Color for: %1": "颜色：%1",
            "Pick a color": "选择颜色",
            "Cancel": "取消",
            "Used:": "已使用：",
            "Extracting…": "提取中…",
            "Auto (from icon)": "自动（从图标）",
            "OK": "确定",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "临时覆盖特定窗口的颜色。关闭窗口时覆盖将丢失。",
            "No windows detected — open some windows to use per-window overrides.":
                "未检测到窗口——请打开窗口以使用单窗口覆盖。",
            "Reset to app color": "重置为应用颜色",
            "Window color override": "窗口颜色覆盖",
            "Configure how colors are displayed on task manager entries.":
                "配置任务管理器条目上的颜色显示方式。",
            "Mode": "模式",
            "How the color overlay is rendered on each task.":
                "颜色叠加在每个任务上的渲染方式。",
            "Thickness": "厚度",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "边框/线条厚度。自动从主题 SVG 边距读取。",
            "Opacity": "不透明度",
            "Background fill intensity.": "背景填充强度。",
            "Corners": "圆角",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "圆角弧度。自动匹配当前主题。最大 = 完美圆形。",
            "Behavior": "行为",
            "Show color on pinned favorites even when no window is open.":
                "即使没有打开窗口，也在固定收藏上显示颜色。",
            "Keep color on focused task": "在聚焦任务上保持颜色",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "叠加层保持在 Plasma 焦点高亮上方可见（80% 背景 + 顶部强调线）。",
            "Version %1": "版本 %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "为 Plasma 任务管理器提供按应用和按窗口的颜色叠加。",
            "Author": "作者",
            "Disabled — toggle switch above to enable": "已禁用——请开启上方开关",
            "Must be placed in a panel": "必须放置在面板中",
            "Disabled": "已禁用",
            "%1 application(s) colored": "已着色 %1 个应用",
            "Click to assign colors": "点击分配颜色",
        },
    },
    "ja": {
        "language": "Japanese",
        "team": "Japanese <ja@li.org>",
        "strings": {
            "General": "一般",
            "General:": "一般:",
            "Enable color overlays": "カラーオーバーレイを有効にする",
            "Color mode:": "カラーモード:",
            "Frame (all sides)": "フレーム（全辺）",
            "Top line": "上部ライン",
            "Bottom line": "下部ライン",
            "Left line": "左ライン",
            "Right line": "右ライン",
            "Top + Bottom": "上 + 下",
            "Left + Right": "左 + 右",
            "Background": "背景",
            "Background + Frame": "背景 + フレーム",
            "Diagonal \\": "対角線 \\",
            "Diagonal /": "対角線 /",
            "Diagonal ✕": "対角線 ✕",
            "Thickness:": "太さ:",
            "Auto": "自動",
            "Corner radius:": "角の半径:",
            "Background opacity:": "背景の不透明度:",
            "Pinned apps:": "ピン留めアプリ:",
            "Always colored": "常に色付き",
            "Only when running": "実行中のみ",
            "Focus:": "フォーカス:",
            "Keep color visible on focused task": "フォーカスされたタスクで色を表示し続ける",
            "Colors:": "色:",
            "%1 application(s) configured": "%1 個のアプリケーションを設定済み",
            "No colors configured": "色が設定されていません",
            "Click again to confirm": "確認するにはもう一度クリック",
            "Reset all colors": "すべての色をリセット",
            "Task Manager Colors": "タスクマネージャーカラー",
            "Applications": "アプリケーション",
            "Windows (%1)": "ウィンドウ (%1)",
            "Settings": "設定",
            "About": "このプログラムについて",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "各アプリケーションに固定色を割り当てます。色はそのアプリケーションのすべてのウィンドウに適用されます。",
            "No tasks detected — open some windows to assign colors.":
                "タスクが検出されません — ウィンドウを開いて色を割り当ててください。",
            "(pinned)": "（ピン留め）",
            "Remove color": "色を削除",
            "Color for: %1": "%1 の色",
            "Pick a color": "色を選択",
            "Cancel": "キャンセル",
            "Used:": "使用中:",
            "Extracting…": "抽出中…",
            "Auto (from icon)": "自動（アイコンから）",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "特定のウィンドウの色を一時的に上書きします。ウィンドウを閉じると上書きは失われます。",
            "No windows detected — open some windows to use per-window overrides.":
                "ウィンドウが検出されません — ウィンドウを開いてウィンドウごとの上書きを使用してください。",
            "Reset to app color": "アプリの色にリセット",
            "Window color override": "ウィンドウ色の上書き",
            "Configure how colors are displayed on task manager entries.":
                "タスクマネージャーのエントリでの色の表示方法を設定します。",
            "Mode": "モード",
            "How the color overlay is rendered on each task.":
                "各タスクでのカラーオーバーレイのレンダリング方法。",
            "Thickness": "太さ",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "枠線/ラインの太さ。自動はテーマのSVGマージンから読み取ります。",
            "Opacity": "不透明度",
            "Background fill intensity.": "背景の塗りつぶし強度。",
            "Corners": "角",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "角の丸み。自動は現在のテーマに合わせます。最大 = 正円。",
            "Behavior": "動作",
            "Show color on pinned favorites even when no window is open.":
                "ウィンドウが開いていなくてもピン留めされたお気に入りに色を表示します。",
            "Keep color on focused task": "フォーカスされたタスクの色を保持",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "オーバーレイはPlasmaのフォーカスハイライトの上に表示されたままになります（80%背景 + 上部アクセントライン）。",
            "Version %1": "バージョン %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Plasmaタスクマネージャー用のアプリケーションごと・ウィンドウごとのカラーオーバーレイ。",
            "Author": "作者",
            "Disabled — toggle switch above to enable": "無効 — 上のスイッチをオンにして有効化",
            "Must be placed in a panel": "パネルに配置する必要があります",
            "Disabled": "無効",
            "%1 application(s) colored": "%1 個のアプリケーションに色付け済み",
            "Click to assign colors": "クリックして色を割り当て",
        },
    },
    "ko": {
        "language": "Korean",
        "team": "Korean <ko@li.org>",
        "strings": {
            "General": "일반",
            "General:": "일반:",
            "Enable color overlays": "색상 오버레이 활성화",
            "Color mode:": "색상 모드:",
            "Frame (all sides)": "프레임 (모든 면)",
            "Top line": "상단 선",
            "Bottom line": "하단 선",
            "Left line": "왼쪽 선",
            "Right line": "오른쪽 선",
            "Top + Bottom": "상단 + 하단",
            "Left + Right": "왼쪽 + 오른쪽",
            "Background": "배경",
            "Background + Frame": "배경 + 프레임",
            "Diagonal \\": "대각선 \\",
            "Diagonal /": "대각선 /",
            "Diagonal ✕": "대각선 ✕",
            "Thickness:": "두께:",
            "Auto": "자동",
            "Corner radius:": "모서리 반경:",
            "Background opacity:": "배경 불투명도:",
            "Pinned apps:": "고정된 앱:",
            "Always colored": "항상 색상 표시",
            "Only when running": "실행 중일 때만",
            "Focus:": "포커스:",
            "Keep color visible on focused task": "포커스된 작업에서 색상 유지",
            "Colors:": "색상:",
            "%1 application(s) configured": "%1개 애플리케이션 구성됨",
            "No colors configured": "구성된 색상 없음",
            "Click again to confirm": "확인하려면 다시 클릭",
            "Reset all colors": "모든 색상 초기화",
            "Task Manager Colors": "작업 관리자 색상",
            "Applications": "애플리케이션",
            "Windows (%1)": "창 (%1)",
            "Settings": "설정",
            "About": "정보",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "각 애플리케이션에 고정 색상을 할당합니다. 색상은 해당 애플리케이션의 모든 창에 적용됩니다.",
            "No tasks detected — open some windows to assign colors.":
                "작업이 감지되지 않음 — 창을 열어 색상을 할당하세요.",
            "(pinned)": "(고정됨)",
            "Remove color": "색상 제거",
            "Color for: %1": "%1의 색상",
            "Pick a color": "색상 선택",
            "Cancel": "취소",
            "Used:": "사용 중:",
            "Extracting…": "추출 중…",
            "Auto (from icon)": "자동 (아이콘에서)",
            "OK": "확인",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "특정 창의 색상을 임시로 재정의합니다. 창을 닫으면 재정의가 사라집니다.",
            "No windows detected — open some windows to use per-window overrides.":
                "창이 감지되지 않음 — 창을 열어 창별 재정의를 사용하세요.",
            "Reset to app color": "앱 색상으로 초기화",
            "Window color override": "창 색상 재정의",
            "Configure how colors are displayed on task manager entries.":
                "작업 관리자 항목에 색상이 표시되는 방식을 구성합니다.",
            "Mode": "모드",
            "How the color overlay is rendered on each task.":
                "각 작업에서 색상 오버레이가 렌더링되는 방식.",
            "Thickness": "두께",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "테두리/선 두께. 자동은 테마 SVG 여백에서 읽습니다.",
            "Opacity": "불투명도",
            "Background fill intensity.": "배경 채우기 강도.",
            "Corners": "모서리",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "모서리 둥글기. 자동은 현재 테마에 맞춤. 최대 = 완벽한 원.",
            "Behavior": "동작",
            "Show color on pinned favorites even when no window is open.":
                "창이 열려 있지 않아도 고정된 즐겨찾기에 색상을 표시합니다.",
            "Keep color on focused task": "포커스된 작업의 색상 유지",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "오버레이가 Plasma 포커스 하이라이트 위에 표시됩니다 (80% 배경 + 상단 강조 선).",
            "Version %1": "버전 %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Plasma 작업 관리자용 애플리케이션별 및 창별 색상 오버레이.",
            "Author": "작성자",
            "Disabled — toggle switch above to enable": "비활성화됨 — 위의 스위치를 켜서 활성화",
            "Must be placed in a panel": "패널에 배치해야 합니다",
            "Disabled": "비활성화됨",
            "%1 application(s) colored": "%1개 애플리케이션 색상 적용됨",
            "Click to assign colors": "클릭하여 색상 할당",
        },
    },
    "it": {
        "language": "Italian",
        "team": "Italian <it@li.org>",
        "strings": {
            "General": "Generale",
            "General:": "Generale:",
            "Enable color overlays": "Attiva sovrapposizioni di colore",
            "Color mode:": "Modalità colore:",
            "Frame (all sides)": "Cornice (tutti i lati)",
            "Top line": "Linea superiore",
            "Bottom line": "Linea inferiore",
            "Left line": "Linea sinistra",
            "Right line": "Linea destra",
            "Top + Bottom": "Sopra + Sotto",
            "Left + Right": "Sinistra + Destra",
            "Background": "Sfondo",
            "Background + Frame": "Sfondo + Cornice",
            "Diagonal \\": "Diagonale \\",
            "Diagonal /": "Diagonale /",
            "Diagonal ✕": "Diagonale ✕",
            "Thickness:": "Spessore:",
            "Auto": "Auto",
            "Corner radius:": "Raggio degli angoli:",
            "Background opacity:": "Opacità dello sfondo:",
            "Pinned apps:": "App fissate:",
            "Always colored": "Sempre colorate",
            "Only when running": "Solo in esecuzione",
            "Focus:": "Focus:",
            "Keep color visible on focused task": "Mantieni colore visibile sull'attività in primo piano",
            "Colors:": "Colori:",
            "%1 application(s) configured": "%1 applicazione/i configurata/e",
            "No colors configured": "Nessun colore configurato",
            "Click again to confirm": "Fai clic di nuovo per confermare",
            "Reset all colors": "Reimposta tutti i colori",
            "Task Manager Colors": "Colori del gestore attività",
            "Applications": "Applicazioni",
            "Windows (%1)": "Finestre (%1)",
            "Settings": "Impostazioni",
            "About": "Informazioni",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Assegna un colore persistente a ogni applicazione. Il colore si applica a tutte le finestre dell'applicazione.",
            "No tasks detected — open some windows to assign colors.":
                "Nessuna attività rilevata — apri delle finestre per assegnare i colori.",
            "(pinned)": "(fissata)",
            "Remove color": "Rimuovi colore",
            "Color for: %1": "Colore per: %1",
            "Pick a color": "Scegli un colore",
            "Cancel": "Annulla",
            "Used:": "Usati:",
            "Extracting…": "Estrazione…",
            "Auto (from icon)": "Auto (dall'icona)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Sovrascrivi temporaneamente il colore di una finestra specifica. Le sovrascritture si perdono alla chiusura della finestra.",
            "No windows detected — open some windows to use per-window overrides.":
                "Nessuna finestra rilevata — apri delle finestre per le sovrascritture per finestra.",
            "Reset to app color": "Reimposta al colore dell'app",
            "Window color override": "Sovrascrittura colore finestra",
            "Configure how colors are displayed on task manager entries.":
                "Configura come i colori vengono visualizzati sulle voci del gestore attività.",
            "Mode": "Modalità",
            "How the color overlay is rendered on each task.":
                "Come la sovrapposizione di colore viene renderizzata su ogni attività.",
            "Thickness": "Spessore",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Spessore del bordo/linea. Auto legge dai margini SVG del tema.",
            "Opacity": "Opacità",
            "Background fill intensity.": "Intensità del riempimento dello sfondo.",
            "Corners": "Angoli",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Arrotondamento degli angoli. Auto corrisponde al tema attuale. Max = cerchio perfetto.",
            "Behavior": "Comportamento",
            "Show color on pinned favorites even when no window is open.":
                "Mostra colore sui preferiti fissati anche senza finestre aperte.",
            "Keep color on focused task": "Mantieni colore sull'attività in primo piano",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "La sovrapposizione resta visibile sopra l'evidenziazione del focus di Plasma (80% sfondo + linea d'accento superiore).",
            "Version %1": "Versione %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Sovrapposizioni di colore per applicazione e per finestra per il gestore attività di Plasma.",
            "Author": "Autore",
            "Disabled — toggle switch above to enable": "Disattivato — attiva l'interruttore sopra",
            "Must be placed in a panel": "Deve essere posizionato in un pannello",
            "Disabled": "Disattivato",
            "%1 application(s) colored": "%1 applicazione/i colorata/e",
            "Click to assign colors": "Fai clic per assegnare i colori",
        },
    },
    "nl": {
        "language": "Dutch",
        "team": "Dutch <nl@li.org>",
        "strings": {
            "General": "Algemeen",
            "General:": "Algemeen:",
            "Enable color overlays": "Kleuroverlays inschakelen",
            "Color mode:": "Kleurmodus:",
            "Frame (all sides)": "Kader (alle zijden)",
            "Top line": "Bovenlijn",
            "Bottom line": "Onderlijn",
            "Left line": "Linkerlijn",
            "Right line": "Rechterlijn",
            "Top + Bottom": "Boven + Onder",
            "Left + Right": "Links + Rechts",
            "Background": "Achtergrond",
            "Background + Frame": "Achtergrond + Kader",
            "Diagonal \\": "Diagonaal \\",
            "Diagonal /": "Diagonaal /",
            "Diagonal ✕": "Diagonaal ✕",
            "Thickness:": "Dikte:",
            "Auto": "Auto",
            "Corner radius:": "Hoekradius:",
            "Background opacity:": "Achtergronddekking:",
            "Pinned apps:": "Vastgezette apps:",
            "Always colored": "Altijd gekleurd",
            "Only when running": "Alleen bij uitvoering",
            "Focus:": "Focus:",
            "Keep color visible on focused task": "Kleur zichtbaar houden op gefocuste taak",
            "Colors:": "Kleuren:",
            "%1 application(s) configured": "%1 toepassing(en) geconfigureerd",
            "No colors configured": "Geen kleuren geconfigureerd",
            "Click again to confirm": "Klik opnieuw om te bevestigen",
            "Reset all colors": "Alle kleuren herstellen",
            "Task Manager Colors": "Taakbeheer kleuren",
            "Applications": "Toepassingen",
            "Windows (%1)": "Vensters (%1)",
            "Settings": "Instellingen",
            "About": "Over",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Ken een vaste kleur toe aan elke toepassing. De kleur geldt voor alle vensters van die toepassing.",
            "No tasks detected — open some windows to assign colors.":
                "Geen taken gedetecteerd — open vensters om kleuren toe te wijzen.",
            "(pinned)": "(vastgezet)",
            "Remove color": "Kleur verwijderen",
            "Color for: %1": "Kleur voor: %1",
            "Pick a color": "Kies een kleur",
            "Cancel": "Annuleren",
            "Used:": "Gebruikt:",
            "Extracting…": "Extraheren…",
            "Auto (from icon)": "Auto (van pictogram)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Overschrijf tijdelijk de kleur van een specifiek venster. Overschrijvingen gaan verloren bij sluiten van het venster.",
            "No windows detected — open some windows to use per-window overrides.":
                "Geen vensters gedetecteerd — open vensters voor vensterspecifieke overschrijvingen.",
            "Reset to app color": "Herstellen naar app-kleur",
            "Window color override": "Vensterkleur overschrijven",
            "Configure how colors are displayed on task manager entries.":
                "Configureer hoe kleuren worden weergegeven op taakbeheer-items.",
            "Mode": "Modus",
            "How the color overlay is rendered on each task.":
                "Hoe de kleuroverlay op elke taak wordt gerenderd.",
            "Thickness": "Dikte",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Rand/lijndikte. Auto leest uit de SVG-marges van het thema.",
            "Opacity": "Dekking",
            "Background fill intensity.": "Achtergrondvulintensiteit.",
            "Corners": "Hoeken",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Hoekafronding. Auto past bij het huidige thema. Max = perfecte cirkel.",
            "Behavior": "Gedrag",
            "Show color on pinned favorites even when no window is open.":
                "Kleur tonen op vastgezette favorieten, ook zonder geopende vensters.",
            "Keep color on focused task": "Kleur behouden op gefocuste taak",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Overlay blijft zichtbaar boven Plasma's focusmarkering (80% achtergrond + bovenste accentlijn).",
            "Version %1": "Versie %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Kleuroverlays per toepassing en per venster voor het Plasma-taakbeheer.",
            "Author": "Auteur",
            "Disabled — toggle switch above to enable": "Uitgeschakeld — schakel de schakelaar hierboven in",
            "Must be placed in a panel": "Moet in een paneel geplaatst worden",
            "Disabled": "Uitgeschakeld",
            "%1 application(s) colored": "%1 toepassing(en) gekleurd",
            "Click to assign colors": "Klik om kleuren toe te wijzen",
        },
    },
    "pl": {
        "language": "Polish",
        "team": "Polish <pl@li.org>",
        "strings": {
            "General": "Ogólne",
            "General:": "Ogólne:",
            "Enable color overlays": "Włącz nakładki kolorów",
            "Color mode:": "Tryb koloru:",
            "Frame (all sides)": "Ramka (wszystkie strony)",
            "Top line": "Górna linia",
            "Bottom line": "Dolna linia",
            "Left line": "Lewa linia",
            "Right line": "Prawa linia",
            "Top + Bottom": "Góra + Dół",
            "Left + Right": "Lewo + Prawo",
            "Background": "Tło",
            "Background + Frame": "Tło + Ramka",
            "Diagonal \\": "Przekątna \\",
            "Diagonal /": "Przekątna /",
            "Diagonal ✕": "Przekątna ✕",
            "Thickness:": "Grubość:",
            "Auto": "Auto",
            "Corner radius:": "Promień narożników:",
            "Background opacity:": "Krycie tła:",
            "Pinned apps:": "Przypięte aplikacje:",
            "Always colored": "Zawsze kolorowe",
            "Only when running": "Tylko podczas działania",
            "Focus:": "Fokus:",
            "Keep color visible on focused task": "Zachowaj kolor na aktywnym zadaniu",
            "Colors:": "Kolory:",
            "%1 application(s) configured": "Skonfigurowano %1 aplikacji",
            "No colors configured": "Brak skonfigurowanych kolorów",
            "Click again to confirm": "Kliknij ponownie, aby potwierdzić",
            "Reset all colors": "Zresetuj wszystkie kolory",
            "Task Manager Colors": "Kolory menedżera zadań",
            "Applications": "Aplikacje",
            "Windows (%1)": "Okna (%1)",
            "Settings": "Ustawienia",
            "About": "O programie",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Przypisz trwały kolor do każdej aplikacji. Kolor dotyczy wszystkich okien tej aplikacji.",
            "No tasks detected — open some windows to assign colors.":
                "Nie wykryto zadań — otwórz okna, aby przypisać kolory.",
            "(pinned)": "(przypięta)",
            "Remove color": "Usuń kolor",
            "Color for: %1": "Kolor dla: %1",
            "Pick a color": "Wybierz kolor",
            "Cancel": "Anuluj",
            "Used:": "Używane:",
            "Extracting…": "Wyodrębnianie…",
            "Auto (from icon)": "Auto (z ikony)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Tymczasowo nadpisz kolor konkretnego okna. Nadpisania są tracone po zamknięciu okna.",
            "No windows detected — open some windows to use per-window overrides.":
                "Nie wykryto okien — otwórz okna, aby użyć nadpisań na okno.",
            "Reset to app color": "Zresetuj do koloru aplikacji",
            "Window color override": "Nadpisanie koloru okna",
            "Configure how colors are displayed on task manager entries.":
                "Skonfiguruj sposób wyświetlania kolorów na wpisach menedżera zadań.",
            "Mode": "Tryb",
            "How the color overlay is rendered on each task.":
                "Sposób renderowania nakładki koloru na każdym zadaniu.",
            "Thickness": "Grubość",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Grubość obramowania/linii. Auto odczytuje z marginesów SVG motywu.",
            "Opacity": "Krycie",
            "Background fill intensity.": "Intensywność wypełnienia tła.",
            "Corners": "Narożniki",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Zaokrąglenie narożników. Auto dopasowuje do bieżącego motywu. Maks = idealny okrąg.",
            "Behavior": "Zachowanie",
            "Show color on pinned favorites even when no window is open.":
                "Pokaż kolor na przypiętych ulubionych nawet bez otwartych okien.",
            "Keep color on focused task": "Zachowaj kolor na aktywnym zadaniu",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Nakładka pozostaje widoczna nad podświetleniem fokusu Plasmy (80% tło + górna linia akcentu).",
            "Version %1": "Wersja %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Nakładki kolorów per aplikacja i per okno dla menedżera zadań Plasmy.",
            "Author": "Autor",
            "Disabled — toggle switch above to enable": "Wyłączone — włącz przełącznik powyżej",
            "Must be placed in a panel": "Musi być umieszczony na panelu",
            "Disabled": "Wyłączone",
            "%1 application(s) colored": "Pokolorowano %1 aplikacji",
            "Click to assign colors": "Kliknij, aby przypisać kolory",
        },
    },
    "tr": {
        "language": "Turkish",
        "team": "Turkish <tr@li.org>",
        "strings": {
            "General": "Genel",
            "General:": "Genel:",
            "Enable color overlays": "Renk katmanlarını etkinleştir",
            "Color mode:": "Renk modu:",
            "Frame (all sides)": "Çerçeve (tüm kenarlar)",
            "Top line": "Üst çizgi",
            "Bottom line": "Alt çizgi",
            "Left line": "Sol çizgi",
            "Right line": "Sağ çizgi",
            "Top + Bottom": "Üst + Alt",
            "Left + Right": "Sol + Sağ",
            "Background": "Arka plan",
            "Background + Frame": "Arka plan + Çerçeve",
            "Diagonal \\": "Çapraz \\",
            "Diagonal /": "Çapraz /",
            "Diagonal ✕": "Çapraz ✕",
            "Thickness:": "Kalınlık:",
            "Auto": "Otomatik",
            "Corner radius:": "Köşe yarıçapı:",
            "Background opacity:": "Arka plan opaklığı:",
            "Pinned apps:": "Sabitlenmiş uygulamalar:",
            "Always colored": "Her zaman renkli",
            "Only when running": "Yalnızca çalışırken",
            "Focus:": "Odak:",
            "Keep color visible on focused task": "Odaklanılan görevde rengi görünür tut",
            "Colors:": "Renkler:",
            "%1 application(s) configured": "%1 uygulama yapılandırıldı",
            "No colors configured": "Yapılandırılmış renk yok",
            "Click again to confirm": "Onaylamak için tekrar tıklayın",
            "Reset all colors": "Tüm renkleri sıfırla",
            "Task Manager Colors": "Görev Yöneticisi Renkleri",
            "Applications": "Uygulamalar",
            "Windows (%1)": "Pencereler (%1)",
            "Settings": "Ayarlar",
            "About": "Hakkında",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Her uygulamaya kalıcı bir renk atayın. Renk, o uygulamanın tüm pencerelerine uygulanır.",
            "No tasks detected — open some windows to assign colors.":
                "Görev algılanmadı — renk atamak için pencere açın.",
            "(pinned)": "(sabitlenmiş)",
            "Remove color": "Rengi kaldır",
            "Color for: %1": "%1 için renk",
            "Pick a color": "Bir renk seçin",
            "Cancel": "İptal",
            "Used:": "Kullanılan:",
            "Extracting…": "Çıkarılıyor…",
            "Auto (from icon)": "Otomatik (simgeden)",
            "OK": "Tamam",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Belirli bir pencerenin rengini geçici olarak geçersiz kılın. Pencere kapatıldığında geçersiz kılmalar kaybolur.",
            "No windows detected — open some windows to use per-window overrides.":
                "Pencere algılanmadı — pencere başına geçersiz kılma kullanmak için pencere açın.",
            "Reset to app color": "Uygulama rengine sıfırla",
            "Window color override": "Pencere rengi geçersiz kılma",
            "Configure how colors are displayed on task manager entries.":
                "Renklerin görev yöneticisi girişlerinde nasıl görüntüleneceğini yapılandırın.",
            "Mode": "Mod",
            "How the color overlay is rendered on each task.":
                "Renk katmanının her görevde nasıl işlendiği.",
            "Thickness": "Kalınlık",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Kenarlık/çizgi kalınlığı. Otomatik, tema SVG kenar boşluklarından okur.",
            "Opacity": "Opaklık",
            "Background fill intensity.": "Arka plan dolgu yoğunluğu.",
            "Corners": "Köşeler",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Köşe yuvarlatma. Otomatik geçerli temaya uyar. Maks = mükemmel daire.",
            "Behavior": "Davranış",
            "Show color on pinned favorites even when no window is open.":
                "Pencere açık olmasa bile sabitlenmiş sık kullanılanlarda rengi göster.",
            "Keep color on focused task": "Odaklanılan görevde rengi koru",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Katman, Plasma'nın odak vurgulamasının üzerinde görünür kalır (%80 arka plan + üst vurgu çizgisi).",
            "Version %1": "Sürüm %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Plasma görev yöneticisi için uygulama ve pencere başına renk katmanları.",
            "Author": "Yazar",
            "Disabled — toggle switch above to enable": "Devre dışı — etkinleştirmek için yukarıdaki anahtarı açın",
            "Must be placed in a panel": "Bir panele yerleştirilmelidir",
            "Disabled": "Devre dışı",
            "%1 application(s) colored": "%1 uygulama renklendirildi",
            "Click to assign colors": "Renk atamak için tıklayın",
        },
    },
    "ar": {
        "language": "Arabic",
        "team": "Arabic <ar@li.org>",
        "strings": {
            "General": "عام",
            "General:": "عام:",
            "Enable color overlays": "تفعيل طبقات الألوان",
            "Color mode:": "وضع اللون:",
            "Frame (all sides)": "إطار (جميع الجوانب)",
            "Top line": "خط علوي",
            "Bottom line": "خط سفلي",
            "Left line": "خط يساري",
            "Right line": "خط يميني",
            "Top + Bottom": "أعلى + أسفل",
            "Left + Right": "يسار + يمين",
            "Background": "خلفية",
            "Background + Frame": "خلفية + إطار",
            "Diagonal \\": "قطري \\",
            "Diagonal /": "قطري /",
            "Diagonal ✕": "قطري ✕",
            "Thickness:": "السُمك:",
            "Auto": "تلقائي",
            "Corner radius:": "نصف قطر الزوايا:",
            "Background opacity:": "عتامة الخلفية:",
            "Pinned apps:": "التطبيقات المثبتة:",
            "Always colored": "ملونة دائمًا",
            "Only when running": "فقط عند التشغيل",
            "Focus:": "التركيز:",
            "Keep color visible on focused task": "إبقاء اللون مرئيًا على المهمة النشطة",
            "Colors:": "الألوان:",
            "%1 application(s) configured": "تم تكوين %1 تطبيق(ات)",
            "No colors configured": "لم يتم تكوين ألوان",
            "Click again to confirm": "انقر مرة أخرى للتأكيد",
            "Reset all colors": "إعادة تعيين جميع الألوان",
            "Task Manager Colors": "ألوان مدير المهام",
            "Applications": "التطبيقات",
            "Windows (%1)": "النوافذ (%1)",
            "Settings": "الإعدادات",
            "About": "حول",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "تعيين لون دائم لكل تطبيق. يُطبّق اللون على جميع نوافذ هذا التطبيق.",
            "No tasks detected — open some windows to assign colors.":
                "لم يتم اكتشاف مهام — افتح نوافذ لتعيين الألوان.",
            "(pinned)": "(مثبت)",
            "Remove color": "إزالة اللون",
            "Color for: %1": "لون لـ: %1",
            "Pick a color": "اختر لونًا",
            "Cancel": "إلغاء",
            "Used:": "مستخدمة:",
            "Extracting…": "جارٍ الاستخراج…",
            "Auto (from icon)": "تلقائي (من الأيقونة)",
            "OK": "موافق",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "تجاوز لون نافذة معينة مؤقتًا. تُفقد التجاوزات عند إغلاق النافذة.",
            "No windows detected — open some windows to use per-window overrides.":
                "لم يتم اكتشاف نوافذ — افتح نوافذ لاستخدام التجاوزات لكل نافذة.",
            "Reset to app color": "إعادة التعيين إلى لون التطبيق",
            "Window color override": "تجاوز لون النافذة",
            "Configure how colors are displayed on task manager entries.":
                "تكوين كيفية عرض الألوان على إدخالات مدير المهام.",
            "Mode": "الوضع",
            "How the color overlay is rendered on each task.":
                "كيفية عرض طبقة اللون على كل مهمة.",
            "Thickness": "السُمك",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "سُمك الحدود/الخط. التلقائي يقرأ من هوامش SVG للسمة.",
            "Opacity": "العتامة",
            "Background fill intensity.": "شدة ملء الخلفية.",
            "Corners": "الزوايا",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "تدوير الزوايا. التلقائي يتطابق مع السمة الحالية. الحد الأقصى = دائرة مثالية.",
            "Behavior": "السلوك",
            "Show color on pinned favorites even when no window is open.":
                "إظهار اللون على المفضلة المثبتة حتى بدون نوافذ مفتوحة.",
            "Keep color on focused task": "الاحتفاظ باللون على المهمة النشطة",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "تبقى الطبقة مرئية فوق تمييز تركيز Plasma (80% خلفية + خط تمييز علوي).",
            "Version %1": "الإصدار %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "طبقات ألوان لكل تطبيق ولكل نافذة لمدير مهام Plasma.",
            "Author": "المؤلف",
            "Disabled — toggle switch above to enable": "معطل — فعّل المفتاح أعلاه",
            "Must be placed in a panel": "يجب وضعه في لوحة",
            "Disabled": "معطل",
            "%1 application(s) colored": "تم تلوين %1 تطبيق(ات)",
            "Click to assign colors": "انقر لتعيين الألوان",
        },
    },
    "uk": {
        "language": "Ukrainian",
        "team": "Ukrainian <uk@li.org>",
        "strings": {
            "General": "Загальні",
            "General:": "Загальні:",
            "Enable color overlays": "Увімкнути кольорові накладки",
            "Color mode:": "Режим кольору:",
            "Frame (all sides)": "Рамка (всі сторони)",
            "Top line": "Верхня лінія",
            "Bottom line": "Нижня лінія",
            "Left line": "Ліва лінія",
            "Right line": "Права лінія",
            "Top + Bottom": "Верх + Низ",
            "Left + Right": "Ліво + Право",
            "Background": "Тло",
            "Background + Frame": "Тло + Рамка",
            "Diagonal \\": "Діагональ \\",
            "Diagonal /": "Діагональ /",
            "Diagonal ✕": "Діагональ ✕",
            "Thickness:": "Товщина:",
            "Auto": "Авто",
            "Corner radius:": "Радіус кутів:",
            "Background opacity:": "Непрозорість тла:",
            "Pinned apps:": "Закріплені додатки:",
            "Always colored": "Завжди кольорові",
            "Only when running": "Лише під час виконання",
            "Focus:": "Фокус:",
            "Keep color visible on focused task": "Зберігати колір на активному завданні",
            "Colors:": "Кольори:",
            "%1 application(s) configured": "Налаштовано %1 додатків",
            "No colors configured": "Кольори не налаштовані",
            "Click again to confirm": "Натисніть ще раз для підтвердження",
            "Reset all colors": "Скинути всі кольори",
            "Task Manager Colors": "Кольори менеджера завдань",
            "Applications": "Додатки",
            "Windows (%1)": "Вікна (%1)",
            "Settings": "Налаштування",
            "About": "Про програму",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Призначити постійний колір кожному додатку. Колір застосовується до всіх вікон цього додатку.",
            "No tasks detected — open some windows to assign colors.":
                "Завдання не виявлено — відкрийте вікна для призначення кольорів.",
            "(pinned)": "(закріплено)",
            "Remove color": "Видалити колір",
            "Color for: %1": "Колір для: %1",
            "Pick a color": "Обрати колір",
            "Cancel": "Скасувати",
            "Used:": "Використані:",
            "Extracting…": "Витягування…",
            "Auto (from icon)": "Авто (з піктограми)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Тимчасово перевизначити колір конкретного вікна. Перевизначення втрачаються при закритті вікна.",
            "No windows detected — open some windows to use per-window overrides.":
                "Вікна не виявлено — відкрийте вікна для використання перевизначень по вікнах.",
            "Reset to app color": "Скинути до кольору додатку",
            "Window color override": "Перевизначення кольору вікна",
            "Configure how colors are displayed on task manager entries.":
                "Налаштувати відображення кольорів на записах менеджера завдань.",
            "Mode": "Режим",
            "How the color overlay is rendered on each task.":
                "Як кольорова накладка відображається на кожному завданні.",
            "Thickness": "Товщина",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Товщина межі/лінії. Авто зчитує з SVG-полів теми.",
            "Opacity": "Непрозорість",
            "Background fill intensity.": "Інтенсивність заповнення тла.",
            "Corners": "Кути",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Заокруглення кутів. Авто відповідає поточній темі. Макс = ідеальне коло.",
            "Behavior": "Поведінка",
            "Show color on pinned favorites even when no window is open.":
                "Показувати колір на закріплених обраних навіть без відкритих вікон.",
            "Keep color on focused task": "Зберігати колір на активному завданні",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Накладка залишається видимою над підсвіткою фокусу Plasma (80% тло + верхня акцентна лінія).",
            "Version %1": "Версія %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Кольорові накладки по додатках і по вікнах для менеджера завдань Plasma.",
            "Author": "Автор",
            "Disabled — toggle switch above to enable": "Вимкнено — увімкніть перемикач вище",
            "Must be placed in a panel": "Має бути розміщений на панелі",
            "Disabled": "Вимкнено",
            "%1 application(s) colored": "Розфарбовано %1 додатків",
            "Click to assign colors": "Натисніть для призначення кольорів",
        },
    },
    "cs": {
        "language": "Czech",
        "team": "Czech <cs@li.org>",
        "strings": {
            "General": "Obecné",
            "General:": "Obecné:",
            "Enable color overlays": "Povolit barevné překryvy",
            "Color mode:": "Režim barvy:",
            "Frame (all sides)": "Rámeček (všechny strany)",
            "Top line": "Horní čára",
            "Bottom line": "Dolní čára",
            "Left line": "Levá čára",
            "Right line": "Pravá čára",
            "Top + Bottom": "Nahoře + Dole",
            "Left + Right": "Vlevo + Vpravo",
            "Background": "Pozadí",
            "Background + Frame": "Pozadí + Rámeček",
            "Diagonal \\": "Diagonála \\",
            "Diagonal /": "Diagonála /",
            "Diagonal ✕": "Diagonála ✕",
            "Thickness:": "Tloušťka:",
            "Auto": "Auto",
            "Corner radius:": "Poloměr rohů:",
            "Background opacity:": "Průhlednost pozadí:",
            "Pinned apps:": "Připnuté aplikace:",
            "Always colored": "Vždy obarvené",
            "Only when running": "Pouze za běhu",
            "Focus:": "Zaměření:",
            "Keep color visible on focused task": "Zachovat barvu na zaměřené úloze",
            "Colors:": "Barvy:",
            "%1 application(s) configured": "Nakonfigurováno %1 aplikací",
            "No colors configured": "Žádné barvy nenastaveny",
            "Click again to confirm": "Klikněte znovu pro potvrzení",
            "Reset all colors": "Obnovit všechny barvy",
            "Task Manager Colors": "Barvy správce úloh",
            "Applications": "Aplikace",
            "Windows (%1)": "Okna (%1)",
            "Settings": "Nastavení",
            "About": "O aplikaci",
            "Assign a persistent color to each application. The color applies to all windows of that application.":
                "Přiřaďte trvalou barvu každé aplikaci. Barva se použije na všechna okna dané aplikace.",
            "No tasks detected — open some windows to assign colors.":
                "Nebyly zjištěny žádné úlohy — otevřete okna pro přiřazení barev.",
            "(pinned)": "(připnuto)",
            "Remove color": "Odebrat barvu",
            "Color for: %1": "Barva pro: %1",
            "Pick a color": "Zvolte barvu",
            "Cancel": "Zrušit",
            "Used:": "Používané:",
            "Extracting…": "Extrahování…",
            "Auto (from icon)": "Auto (z ikony)",
            "OK": "OK",
            "Temporarily override the color of a specific window. Overrides are lost when the window is closed.":
                "Dočasně přepsat barvu konkrétního okna. Přepsání se ztratí po zavření okna.",
            "No windows detected — open some windows to use per-window overrides.":
                "Nebyla zjištěna žádná okna — otevřete okna pro přepsání po oknech.",
            "Reset to app color": "Obnovit na barvu aplikace",
            "Window color override": "Přepsání barvy okna",
            "Configure how colors are displayed on task manager entries.":
                "Nastavte způsob zobrazení barev na položkách správce úloh.",
            "Mode": "Režim",
            "How the color overlay is rendered on each task.":
                "Způsob vykreslení barevného překryvu na každé úloze.",
            "Thickness": "Tloušťka",
            "Border/line thickness. Auto reads from theme SVG margins.":
                "Tloušťka okraje/čáry. Auto čte z SVG okrajů motivu.",
            "Opacity": "Průhlednost",
            "Background fill intensity.": "Intenzita vyplnění pozadí.",
            "Corners": "Rohy",
            "Corner rounding. Auto matches current theme. Max = perfect circle.":
                "Zaoblení rohů. Auto odpovídá aktuálnímu motivu. Max = dokonalý kruh.",
            "Behavior": "Chování",
            "Show color on pinned favorites even when no window is open.":
                "Zobrazit barvu na připnutých oblíbených i bez otevřených oken.",
            "Keep color on focused task": "Zachovat barvu na zaměřené úloze",
            "Overlay stays visible above Plasma's focus highlight (80% bg + top accent line).":
                "Překryv zůstane viditelný nad zvýrazněním zaměření Plasma (80% pozadí + horní zvýrazňující čára).",
            "Version %1": "Verze %1",
            "Per-application and per-window color overlays for the Plasma task manager.":
                "Barevné překryvy podle aplikací a oken pro správce úloh Plasma.",
            "Author": "Autor",
            "Disabled — toggle switch above to enable": "Zakázáno — zapněte přepínač výše",
            "Must be placed in a panel": "Musí být umístěn na panelu",
            "Disabled": "Zakázáno",
            "%1 application(s) colored": "Obarveno %1 aplikací",
            "Click to assign colors": "Klikněte pro přiřazení barev",
        },
    },
}


def generate_po(lang, data):
    now = datetime.datetime.now().astimezone().strftime("%Y-%m-%d %H:%M%z")
    year = datetime.datetime.now().year

    # Read template.pot to get msgids in order
    pot_path = os.path.join(DIR, "template.pot")
    with open(pot_path, "r", encoding="utf-8") as f:
        pot_content = f.read()

    lines = []
    lines.append(f"# Translation of Task Manager Colors in {data['language']}")
    lines.append(f"# Copyright (C) {year} David DIVERRES")
    lines.append(f"# This file is distributed under the same license as the colors package.")
    lines.append(f"#")
    lines.append(f"msgid \"\"")
    lines.append(f"msgstr \"\"")
    lines.append(f"\"Project-Id-Version: colors\\n\"")
    lines.append(f"\"Report-Msgid-Bugs-To: https://comexpertise.com\\n\"")
    lines.append(f"\"POT-Creation-Date: {now}\\n\"")
    lines.append(f"\"PO-Revision-Date: {now}\\n\"")
    lines.append(f"\"Last-Translator: David DIVERRES <david@comexpertise.com>\\n\"")
    lines.append(f"\"Language-Team: {data['team']}\\n\"")
    lines.append(f"\"Language: {lang}\\n\"")
    lines.append(f"\"MIME-Version: 1.0\\n\"")
    lines.append(f"\"Content-Type: text/plain; charset=UTF-8\\n\"")
    lines.append(f"\"Content-Transfer-Encoding: 8bit\\n\"")
    lines.append("")

    # Parse template.pot for msgid entries (preserve comments and order)
    import re
    # Split into blocks separated by blank lines
    blocks = pot_content.split("\n\n")
    for block in blocks:
        block = block.strip()
        if not block:
            continue
        # Skip the header block
        if 'msgid ""' in block and 'Project-Id-Version' in block:
            continue

        # Extract msgid
        msgid_match = re.search(r'msgid\s+"((?:[^"\\]|\\.)*)"', block)
        if not msgid_match:
            continue
        msgid = msgid_match.group(1)
        if not msgid:
            continue

        # Get comment lines (file references)
        comment_lines = [l for l in block.split("\n") if l.startswith("#:")]
        flag_lines = [l for l in block.split("\n") if l.startswith("#,")]

        for cl in comment_lines:
            lines.append(cl)
        for fl in flag_lines:
            lines.append(fl)

        # Unescape msgid for lookup
        lookup_key = msgid.replace('\\"', '"').replace('\\\\', '\\').replace('\\n', '\n')

        translation = data["strings"].get(lookup_key, "")
        # Escape for .po format
        escaped_translation = translation.replace('\\', '\\\\').replace('"', '\\"')

        lines.append(f'msgid "{msgid}"')
        lines.append(f'msgstr "{escaped_translation}"')
        lines.append("")

    po_path = os.path.join(DIR, f"{lang}.po")
    with open(po_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    print(f"Generated: {lang}.po ({len(data['strings'])} translations)")


if __name__ == "__main__":
    for lang, data in TRANSLATIONS.items():
        generate_po(lang, data)
    print(f"\nDone: {len(TRANSLATIONS)} locale(s) generated.")
