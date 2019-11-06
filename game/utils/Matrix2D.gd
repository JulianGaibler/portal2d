class_name Matrix2D

# Matrix structure:
# ( x.x x.y )
# ( y.x y.y )

var x: Vector2
var y: Vector2

func _init(xx: float, xy: float, yx: float, yy: float):
    self.x = Vector2(xx, xy)
    self.y = Vector2(yx, yy)

func inverse():
    var mat = get_script().new(self.y.y, -self.x.y, -self.y.x, self.x.x)
    var num = 1 / (self.x.x * self.y.y - self.x.y * self.y.x)
    return mat.multiply_num(num)

func multiply_mat(other: Matrix2D) -> Matrix2D:
    return get_script().new(
        self.x.x * other.x.x + self.x.y * other.y.x,
        self.x.x * other.x.y + self.x.y * other.y.y,
        self.y.x * other.x.x + self.y.y * other.y.x,
        self.y.x * other.x.y + self.y.y * other.y.y)

func multiply_vec(other: Vector2):
    return Vector2(self.x.x * other.x + self.x.y * other.y,
                   self.y.x * other.x + self.y.y * other.y)

func multiply_num(scalar: float):
    return get_script().new(self.x.x * scalar, self.x.y * scalar, self.y.x * scalar, self.y.y * scalar)

func print() -> String:
    return "{ {%2.2f, %2.2f} {%2.2f, %2.2f} }" % [self.x.x, self.x.y, self.y.x, self.y.y]

func toTransform2D() -> Transform2D:
    var tf = Transform2D()
    tf.x.x = x.x
    tf.x.y = y.x
    tf.y.x = x.y
    tf.y.y = y.y
    return tf
