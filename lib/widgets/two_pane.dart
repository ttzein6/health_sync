import 'package:flutter/material.dart';

class TwoPane extends StatelessWidget {
  final Widget startPane;
  final Widget? endPane;
  //Pane proportion should have value between 0 and 1
  final double paneProportion;
  final double? startPaneFixedWidth;
  final PanePriority panePriority;

  const TwoPane({
    super.key,
    required this.startPane,
    this.startPaneFixedWidth,
    this.endPane,
    this.paneProportion = 0.3,
    this.panePriority = PanePriority.proportion,
  }) : assert(paneProportion <= 1 && paneProportion >= 0);

  double getFirstPaneWidth(
      BoxConstraints constraints, PanePriority panePriority) {
    switch (panePriority) {
      case PanePriority.start:
        return constraints.maxWidth;
      case PanePriority.end:
        return 0;
      case PanePriority.proportion:
        if (startPaneFixedWidth != null) return startPaneFixedWidth!;
        return constraints.maxWidth * paneProportion;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double startPaneWidth = getFirstPaneWidth(constraints, panePriority);

        return Flex(
          direction: Axis.horizontal,
          children: [
            if (endPane == null)
              Flexible(child: startPane)
            else
              AnimatedContainer(
                duration: Durations.medium1,
                // Size.fromWidth(startPaneWidth),
                width: startPaneWidth,
                child: startPane,
              ),
            if (endPane != null &&
                (panePriority == PanePriority.proportion ||
                    panePriority == PanePriority.end))
              Flexible(
                child: endPane!,
              ),
          ],
        );
      },
    );
  }
}

enum PanePriority {
  start,
  end,
  proportion,
}
