#ifndef ASSETSWIDGET_H
#define ASSETSWIDGET_H

#include <QFrame>

namespace Ui {
class AssetsWidget;
}

class AssetsWidget : public QFrame
{
    Q_OBJECT

public:
    explicit AssetsWidget(QWidget *parent = nullptr);
    ~AssetsWidget();

private slots:
    void on_pushButton_9_clicked();

private:
    Ui::AssetsWidget *ui;
};

#endif // ASSETSWIDGET_H
