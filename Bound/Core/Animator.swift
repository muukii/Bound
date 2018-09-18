
@available(iOS 10, *)
public class Animator {

  public typealias GroupFactory = (TransitionContext, TransitionGroup) throws -> Void
  public typealias Completion = () -> Void

  private var groupFactories: [(GroupFactory, Completion)] = []

  private var wholeCompletion: () -> Void = {}

  private var errorHandlers: [(Error) -> Void] = []

  private weak var avoidingFlickerSnapshot: UIView?

  public init() {

  }
}

extension Animator {

  @discardableResult
  public func addGroupFactory(_ groupFactory: @escaping GroupFactory, completion: @escaping Completion) -> Self {
    self.groupFactories.append((groupFactory, completion))
    return self
  }

  @discardableResult
  public func addWholeCompletion(_ wholeCompletion: @escaping () -> Void) -> Self {
    self.wholeCompletion = wholeCompletion
    return self
  }

  @discardableResult
  public func addErrorHandler(_ handler: @escaping (Error) -> Void) -> Self {
    errorHandlers.append(handler)
    return self
  }

  /// Start animations
  ///
  /// - Parameters:
  ///   - containerView:
  ///   - shouldAvoidFlicker: 
  public func run(
    in containerView: UIView,
    withShouldAvoidFlicker shouldAvoidFlicker: Bool = true
    ) {

    let context = TransitionContext(containerView: containerView)

    /**
     This dispatching is for transition in NavigationController.
     Transition of NavigationController starts on commit of CATransaction.
     It will cause failure to snapshot of UIView.
     */

    /**
     Workaround:
     To take snapshot exactly, It needs to separate CATransaction as two, but this approach may cause flicker.
     To avoid, take the snapshot for containerView and then addSubview.
     Remove this snapshot on second CATransaction.
     */

    /**
     First Transaction
     */

    if shouldAvoidFlicker {
      let avoidingFlickerSnapshot = containerView.snapshotView(afterScreenUpdates: false) ?? UIView()
      containerView.addSubview(avoidingFlickerSnapshot)
      self.avoidingFlickerSnapshot = avoidingFlickerSnapshot
    }

    layout: do {

      /**
       To apply tasks that UIKit has.
       e.g safeAreaInsets, contentInsets
       */ containerView.layoutIfNeeded()
    }

    /**
     Second Transaction
     */

    do {

      let items = try self.groupFactories.map { args -> (TransitionGroup, Completion) in
        let group = TransitionGroup()
        try args.0(context, group)
        return (group, args.1)
      }

      items.forEach {
        $0.0.animations.forEach {
          $0.preProcess()
        }
      }

      avoidingFlickerSnapshot?.removeFromSuperview()

      /**
       Start Animations
       */

      let wholeGroup = DispatchGroup()

      items.forEach { args in

        wholeGroup.enter()

        let group = DispatchGroup()

        args.0.animations.forEach {
          group.enter()
          let set = $0.make()
          set.coldAnimator.startAnimation(afterDelay: set.delay)
          set.coldAnimator.addCompletion { _ in
            group.leave()
          }
        }

        group.notify(queue: .main) {
          wholeGroup.leave()
          args.1()
        }
      }

      wholeGroup.notify(queue: .main) {

        /**
         Animations did finish
         */

        UIView.performWithoutAnimation {
          items.forEach {
            $0.0.animations.forEach {
              $0.postProcess()
            }
          }
        }

        self.wholeCompletion()
      }
    } catch {
      avoidingFlickerSnapshot?.removeFromSuperview()
      self.errorHandlers.forEach { $0(error) }
    }
  }
}
