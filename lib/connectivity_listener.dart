import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:kyc/presentation/blocs/sync_bloc.dart';

class ConnectivityListener {
  final SyncBloc syncBloc;

  ConnectivityListener(this.syncBloc) {
    Connectivity().onConnectivityChanged.listen((status) {
      if (status.contains(ConnectivityResult.wifi)) { // USE InternetAddress.lookup
        syncBloc.add(NetworkOnlineEvent());
      }
    });
  }
}
