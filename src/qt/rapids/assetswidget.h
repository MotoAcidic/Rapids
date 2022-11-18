#ifndef ASSETSWIDGET_H
#define ASSETSWIDGET_H

#include <QFrame>

namespace Ui {
class assetswidget;
}

class assetswidget : public QFrame
{
    Q_OBJECT

public:
    explicit assetswidget(QWidget *parent = nullptr);
    ~assetswidget();

private:
    Ui::assetswidget *ui;
};

#endif // ASSETSWIDGET_H
