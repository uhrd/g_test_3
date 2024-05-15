(defun match-char (board waifu char)
  (let ((match (list)) (ch (subseq waifu char (+ char 1))))
  (dotimes (x (length board))
  (dotimes (y (length (car board)))
    (if (equal ch (nth x (nth y board)))
      (setf match (cons (list x y ch) match))) ))
  match))
(defun find-chars (board waifu)
  (let ((construct (list)))
  (dotimes (c (length waifu))
    (setf construct (cons (match-char board waifu c) construct)))
  (reverse construct) ))
(defun adjacent (cell1 cell2) ; too complicated and unreliable - also matches diagonals
  (if (or (< 1 (length cell1)) (< 1 (length cell2)))
  nil (progn
    (if (or (eq nil cell1) (eq nil cell2) (eq nil (car cell1)) (eq nil (car cell2)))
    nil (progn
      (defun ec (n cell) (nth n (car cell)))
      (let ((x1 (ec 0 cell1)) (y1 (ec 1 cell1)) (x2 (ec 0 cell2)) (y2 (ec 1 cell2)))
	(and (<= (abs (- x1 x2)) 1) (<= (abs (- y1 y2)) 1)) ))))) )
(defun adjacent-cells (board x y)
  (let ((xl (length (car board))) (yl (length board))) (list
    (if (and (< 0 x) (< x xl)) (nth (- x 1) (nth y board)))
    (if (and (< 0 y) (< y yl)) (nth x (nth (- y 1) board)))
    (if (and (< 0 (+ x 1)) (< (+ x 1) xl)) (nth (+ x 1) (nth y board)))
    (if (and (< 0 (+ y 1)) (< (+ y 1) yl)) (nth x (nth (+ y 1) board))) )))
(defun validate-construction (out board chars-list)
  (let ((prev-adjacent (list)) (prev-madjacent (list)) (chain (list)) (char-match (list)))
  (dotimes (c (length chars-list))
    (let ((chars (length (nth c chars-list))) (choose nil)
          (char (nth 2 (car (nth c chars-list))))
          (match (list)) (adjacent-match (list)))
    (flet ((any (m) (reduce #'(lambda (x y) (or x y)) m)))
      (format out "~a    prev-madjacent: ~a ~%" char prev-madjacent)
      (if (= c 0) (setf chain (list char)))
      (dotimes (n chars)
        (let* ((cell (nth n (nth c chars-list)))
               (adjacent (adjacent-cells board (nth 0 cell) (nth 1 cell))))
          (setf char-match (list))
;          (if choose (setf prev-adjacent (adjacent-cells board (nth 0 choose) (nth 1 choose)) ))
          (dolist (adj prev-adjacent)
            (setf match (if (= 4 (length match))
                (list (equal (nth 2 cell) adj)) ; 
                (cons (equal (nth 2 cell) adj) match)) ; reset instead of consing a 5th
              char-match (cons (any match) char-match))
            (format out "selected: ~a   previous: ~14a match: ~a ~%" (nth 2 cell) adj (car match)) )
          (format out "selected: ~a   adjacent: ~14a prev-adjacent: ~14a   char-match: ~a  matches: ~a ~%"
            (nth 2 cell) adjacent prev-adjacent
             (if (< 1 (length char-match)) (car char-match) char-match)  (length match))
          (if (car char-match) (setf prev-madjacent prev-adjacent)) ; to continue the chain
          (setf prev-adjacent (if choose (adjacent-cells board (car choose) (nth 1 choose)) adjacent)
            adjacent-match (cons (any (cons nil char-match)) adjacent-match))
          (if (car adjacent-match) (setf choose (list (nth 0 cell) (nth 1 cell))))
        )
      )
    (format out "chain: ~20a adjacent-match: ~10a choose: ~a ~%"
      (reverse (if ;(car char-match)
  (any (cons nil adjacent-match))
   (setf chain (cons char chain)))) adjacent-match choose)
    ))
  ))
)
(defun construct-waifu (out chars-list) ; exploratory
  (format out "~a ~%" chars-list)
  (dotimes (c (length chars-list))
    (let ((chars (length (nth c chars-list))) (char (nth 2 (car (nth c chars-list)))) (borders-prev 0))
    (format out "~a " (nth c chars-list))
    (if (< 1 chars)
    (progn
      (format out "figure out which of the ~a ~a cells to use ~%" chars char)
      (dotimes (n chars)
        (if (> c 0) (let ((chosen (list (nth borders-prev (nth (- c 1) chars-list)))))
        (if (adjacent chosen (list (nth n (nth c chars-list))))
        (progn
          (format out "~a borders ~a ~%" chosen (list (nth n (nth c chars-list))))
          (setf borders-prev n) )))
        (progn (format out "~a riight ~%" (nth n (nth c chars-list)))) ; look ahead instead
      ))
    )
    (if (adjacent (nth c chars-list) (nth (+ c 1) chars-list))
      (format out "is adjacent to ~a ~%" (nth (+ c 1) chars-list))
      (format out "uhh ~%") ))
    )
  )
  (format out "~%")
)
(defun check-waifus (board waifu-list)
  (dolist (waifu waifu-list)
;    (construct-waifu t (find-chars board waifu))
    (validate-construction t board (find-chars board waifu))
  )
)
(defun main ()
  (let ((board 
  '(("M" "O" "N" "I")
    ("L" "K" "S" "K")
    ("W" "D" "S" "A")
    ("A" "K" "U" "Y")))
    (waifu-list '("MONIKA" "ASUKA" "HARUHI")))
  (check-waifus board waifu-list) ))
(if nil (progn
  (require 'asdf)
  (setq uiop:*image-entry-point* #'main)
  (uiop:dump-image (uiop:native-namestring "~/.local/bin/g_test_3") :executable t)))
