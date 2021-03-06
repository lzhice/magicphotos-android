#ifndef BLUREDITOR_H
#define BLUREDITOR_H

#include <QtCore/QObject>
#include <QtGui/QMouseEvent>
#include <QtGui/QImage>

#include "effecteditor.h"
#include "previewgenerator.h"

class BlurEditor : public EffectEditor
{
    Q_OBJECT

    Q_PROPERTY(int radius READ radius WRITE setRadius)

public:
    explicit BlurEditor(QQuickItem *parent = nullptr);

    BlurEditor(const BlurEditor &) = delete;
    BlurEditor(BlurEditor &&) noexcept = delete;

    BlurEditor &operator=(const BlurEditor &) = delete;
    BlurEditor &operator=(BlurEditor &&) noexcept = delete;

    ~BlurEditor() noexcept override = default;

    int radius() const;
    void setRadius(int radius);

protected:
    void ProcessOpenedImage() override;

private:
    int Radius;
};

class BlurPreviewGenerator : public PreviewGenerator
{
    Q_OBJECT

    Q_PROPERTY(int radius READ radius WRITE setRadius)

public:
    explicit BlurPreviewGenerator(QQuickItem *parent = nullptr);

    BlurPreviewGenerator(const BlurPreviewGenerator &) = delete;
    BlurPreviewGenerator(BlurPreviewGenerator &&) noexcept = delete;

    BlurPreviewGenerator &operator=(const BlurPreviewGenerator &) = delete;
    BlurPreviewGenerator &operator=(BlurPreviewGenerator &&) noexcept = delete;

    ~BlurPreviewGenerator() noexcept override = default;

    int radius() const;
    void setRadius(int radius);

protected:
    void StartImageGenerator() override;

private:
    int Radius;
};

class BlurImageGenerator : public QObject
{
    Q_OBJECT

public:
    explicit BlurImageGenerator(QObject *parent = nullptr);

    BlurImageGenerator(const BlurImageGenerator &) = delete;
    BlurImageGenerator(BlurImageGenerator &&) noexcept = delete;

    BlurImageGenerator &operator=(const BlurImageGenerator &) = delete;
    BlurImageGenerator &operator=(BlurImageGenerator &&) noexcept = delete;

    ~BlurImageGenerator() noexcept override = default;

    void SetRadius(int radius);
    void SetInput(const QImage &input_image);

public slots:
    void start();

signals:
    void imageReady(const QImage &outputImage);
    void finished();

private:
    int    Radius;
    QImage InputImage;
};

#endif // BLUREDITOR_H
