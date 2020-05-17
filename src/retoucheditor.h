#ifndef RETOUCHEDITOR_H
#define RETOUCHEDITOR_H

#include <QtCore/QObject>
#include <QtCore/QPoint>
#include <QtGui/QMouseEvent>

#include "editor.h"

class RetouchEditor : public Editor
{
    Q_OBJECT

    Q_PROPERTY(bool   samplingPointValid READ samplingPointValid NOTIFY samplingPointValidChanged)
    Q_PROPERTY(QPoint samplingPoint      READ samplingPoint      NOTIFY samplingPointChanged)

public:
    explicit RetouchEditor(QQuickItem *parent = nullptr);

    RetouchEditor(const RetouchEditor &) = delete;
    RetouchEditor(RetouchEditor &&) noexcept = delete;

    RetouchEditor &operator=(const RetouchEditor &) = delete;
    RetouchEditor &operator=(RetouchEditor &&) noexcept = delete;

    ~RetouchEditor() noexcept override = default;

    bool samplingPointValid() const;
    QPoint samplingPoint() const;

    enum EditorMode {
        ModeScroll,
        ModeSamplingPoint,
        ModeClone,
        ModeBlur
    };
    Q_ENUM(EditorMode)

signals:
    void samplingPointValidChanged(bool samplingPointValid);
    void samplingPointChanged(QPoint samplingPoint);

protected:
    void mousePressEvent(QMouseEvent *event) override;
    void mouseMoveEvent(QMouseEvent *event) override;
    void mouseReleaseEvent(QMouseEvent *event) override;

    void ProcessOpenedImage() override;

private:
    void ChangeImageAt(bool save_undo, int center_x, int center_y);

    static constexpr int BLUR_RADIUS = 4;

    bool   SamplingPointValid, LastBlurPointValid;
    QPoint SamplingPoint, InitialSamplingPoint, LastBlurPoint, InitialTouchPoint;
};

#endif // RETOUCHEDITOR_H
