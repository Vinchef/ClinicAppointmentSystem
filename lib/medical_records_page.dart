import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/medical_record.dart';
import 'services/medical_records_service.dart';
import 'widgets/branding.dart';

class MedicalRecordsPage extends StatefulWidget {
  @override
  _MedicalRecordsPageState createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _userEmail = '';
  String _userName = '';
  List<MedicalRecord> _allRecords = [];
  Map<String, int> _recordCounts = {};
  String _selectedFilter = 'all';
  
  final List<Map<String, dynamic>> _categories = [
    {'type': 'all', 'label': 'All Records', 'icon': Icons.folder_outlined},
    {'type': MedicalRecord.typeAllergy, 'label': 'Allergies', 'icon': Icons.warning_amber_outlined},
    {'type': MedicalRecord.typeDiagnosis, 'label': 'Diagnoses', 'icon': Icons.medical_information_outlined},
    {'type': MedicalRecord.typePrescription, 'label': 'Prescriptions', 'icon': Icons.medication_outlined},
    {'type': MedicalRecord.typeLabResult, 'label': 'Lab Results', 'icon': Icons.science_outlined},
    {'type': MedicalRecord.typeVitals, 'label': 'Vitals', 'icon': Icons.monitor_heart_outlined},
    {'type': MedicalRecord.typeVaccination, 'label': 'Vaccinations', 'icon': Icons.vaccines_outlined},
    {'type': MedicalRecord.typeNote, 'label': 'Notes', 'icon': Icons.note_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('username') ?? '';
    _userName = prefs.getString('fullName') ?? 'User';
    
    // Load records from completed appointments and manual records
    _allRecords = await MedicalRecordsService.getPatientRecords(_userEmail);
    _recordCounts = await MedicalRecordsService.getRecordCounts(_userEmail);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<MedicalRecord> get _filteredRecords {
    if (_selectedFilter == 'all') return _allRecords;
    return _allRecords.where((r) => r.type == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F8FF),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF0091EA)))
          : CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(),
                
                // Health Summary Card
                SliverToBoxAdapter(child: _buildHealthSummary()),
                
                // Category Filter Chips
                SliverToBoxAdapter(child: _buildCategoryFilter()),
                
                // Records List
                _filteredRecords.isEmpty
                    ? SliverFillRemaining(child: _buildEmptyState())
                    : SliverPadding(
                        padding: EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => _buildRecordCard(_filteredRecords[index]),
                            childCount: _filteredRecords.length,
                          ),
                        ),
                      ),
                
                // Bottom padding
                SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: Color(0xFF0091EA),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Medical Records',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0091EA), Color(0xFF1565C0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.08),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () => _showSearchDialog(),
        ),
        IconButton(
          icon: Icon(Icons.download_outlined, color: Colors.white),
          onPressed: () => _showExportDialog(),
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHealthSummary() {
    final allergies = _allRecords.where((r) => r.type == MedicalRecord.typeAllergy).toList();
    final latestVitals = _allRecords.where((r) => r.type == MedicalRecord.typeVitals).toList();
    
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF0091EA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.health_and_safety, color: Color(0xFF0091EA), size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Health Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    Text(
                      '${_allRecords.length} records on file',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          
          // Allergies Alert
          if (allergies.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Color(0xFFFFE0B2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFFF9800).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Color(0xFFE65100), size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Known Allergies',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFE65100),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          allergies.map((a) => a.title).join(', '),
                          style: TextStyle(
                            color: Color(0xFF795548),
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
          ],
          
          // Quick Stats
          Row(
            children: [
              _buildQuickStat(
                '${_recordCounts[MedicalRecord.typePrescription] ?? 0}',
                'Prescriptions',
                Icons.medication,
                Color(0xFF4CAF50),
              ),
              SizedBox(width: 12),
              _buildQuickStat(
                '${_recordCounts[MedicalRecord.typeLabResult] ?? 0}',
                'Lab Results',
                Icons.science,
                Color(0xFF9C27B0),
              ),
              SizedBox(width: 12),
              _buildQuickStat(
                '${_recordCounts[MedicalRecord.typeVaccination] ?? 0}',
                'Vaccines',
                Icons.vaccines,
                Color(0xFF00BCD4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF666666),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedFilter == cat['type'];
          final count = cat['type'] == 'all' 
              ? _allRecords.length 
              : (_recordCounts[cat['type']] ?? 0);
          
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = cat['type']),
            child: Container(
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Color(0xFF0091EA) : Colors.white,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected ? Color(0xFF0091EA) : Color(0xFFE0E0E0),
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Color(0xFF0091EA).withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ] : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    cat['icon'],
                    size: 18,
                    color: isSelected ? Colors.white : Color(0xFF666666),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${cat['label']} ($count)',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    final color = Color(MedicalRecord.getColor(record.type));
    final icon = MedicalRecord.getIcon(record.type);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRecordDetails(record),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(icon, style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A237E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              MedicalRecord.getTypeName(record.type),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFFCCCCCC)),
                  ],
                ),
                SizedBox(height: 14),
                
                // Description
                Text(
                  record.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 14),
                
                // Footer
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Color(0xFF999999)),
                    SizedBox(width: 6),
                    Text(
                      record.doctorName,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.calendar_today_outlined, size: 14, color: Color(0xFF999999)),
                    SizedBox(width: 6),
                    Text(
                      _formatDate(record.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFFF0F4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_outlined,
                size: 64,
                color: Color(0xFF0091EA),
              ),
            ),
            SizedBox(height: 24),
            Text(
              _selectedFilter == 'all' ? 'No Visit History Yet' : 'No Records Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A237E),
              ),
            ),
            SizedBox(height: 12),
            Text(
              _selectedFilter == 'all'
                  ? 'Your medical records will appear here after you complete appointments with our doctors.'
                  : 'No ${MedicalRecord.getTypeName(_selectedFilter).toLowerCase()} records found',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilter == 'all') ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/booking');
                },
                icon: Icon(Icons.calendar_month, color: Colors.white),
                label: Text('Book an Appointment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0091EA),
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showRecordDetails(MedicalRecord record) {
    final color = Color(MedicalRecord.getColor(record.type));
    final icon = MedicalRecord.getIcon(record.type);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(icon, style: TextStyle(fontSize: 32)),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                MedicalRecord.getTypeName(record.type),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              record.title,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      _buildDetailChip(Icons.person, record.doctorName),
                      SizedBox(width: 12),
                      _buildDetailChip(Icons.calendar_today, _formatDate(record.date)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      record.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF666666),
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Type-specific content
                    _buildTypeSpecificContent(record),
                    
                    SizedBox(height: 24),
                    
                    // Doctor Info
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFFF5F8FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(0xFF0091EA),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(Icons.medical_services, color: Colors.white),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.doctorName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A237E),
                                  ),
                                ),
                                Text(
                                  record.doctorSpecialty,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSpecificContent(MedicalRecord record) {
    switch (record.type) {
      case MedicalRecord.typeVitals:
        return _buildVitalsContent(record);
      case MedicalRecord.typePrescription:
        return _buildPrescriptionContent(record);
      case MedicalRecord.typeLabResult:
        return _buildLabResultContent(record);
      case MedicalRecord.typeVaccination:
        return _buildVaccinationContent(record);
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildVitalsContent(MedicalRecord record) {
    final data = record.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vital Signs',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2,
          children: [
            _buildVitalItem('Blood Pressure', '${data['bloodPressureSystolic']?.toInt() ?? '-'}/${data['bloodPressureDiastolic']?.toInt() ?? '-'}', 'mmHg', Icons.favorite),
            _buildVitalItem('Heart Rate', '${data['heartRate']?.toInt() ?? '-'}', 'bpm', Icons.monitor_heart),
            _buildVitalItem('Temperature', '${data['temperature'] ?? '-'}', '°C', Icons.thermostat),
            _buildVitalItem('O2 Saturation', '${data['oxygenSaturation']?.toInt() ?? '-'}', '%', Icons.air),
            _buildVitalItem('Weight', '${data['weight'] ?? '-'}', 'kg', Icons.scale),
            _buildVitalItem('Height', '${data['height']?.toInt() ?? '-'}', 'cm', Icons.height),
          ],
        ),
      ],
    );
  }

  Widget _buildVitalItem(String label, String value, String unit, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color(0xFFF5F8FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Color(0xFF0091EA)),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Color(0xFF666666)),
              ),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionContent(MedicalRecord record) {
    final medications = record.data['medications'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medications',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 16),
        ...medications.map((med) => Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Color(0xFF4CAF50).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.medication, color: Color(0xFF4CAF50)),
                  SizedBox(width: 10),
                  Text(
                    med['medication'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A237E),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildMedChip('Dosage: ${med['dosage'] ?? ''}'),
                  _buildMedChip('${med['frequency'] ?? ''}'),
                  _buildMedChip('Duration: ${med['duration'] ?? ''}'),
                ],
              ),
              if (med['instructions']?.isNotEmpty ?? false) ...[
                SizedBox(height: 10),
                Text(
                  '📝 ${med['instructions']}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildMedChip(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
      ),
    );
  }

  Widget _buildLabResultContent(MedicalRecord record) {
    final results = record.data['results'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 16),
        ...results.map((result) {
          final isNormal = result['status'] == 'normal';
          return Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isNormal ? Color(0xFFE8F5E9) : Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    result['test'] ?? '',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E)),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${result['value']} ${result['unit'] ?? ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isNormal ? Color(0xFF4CAF50) : Color(0xFFE53935),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isNormal ? Color(0xFF4CAF50) : Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isNormal ? 'Normal' : 'Abnormal',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildVaccinationContent(MedicalRecord record) {
    final data = record.data;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vaccination Details',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A237E),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFFE0F7FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _buildVaccineRow('Vaccine', data['vaccine'] ?? '-'),
              Divider(height: 20),
              _buildVaccineRow('Manufacturer', data['manufacturer'] ?? '-'),
              Divider(height: 20),
              _buildVaccineRow('Lot Number', data['lotNumber'] ?? '-'),
              Divider(height: 20),
              _buildVaccineRow('Injection Site', data['site'] ?? '-'),
              if (data['nextDue'] != null) ...[
                Divider(height: 20),
                _buildVaccineRow('Next Due', _formatDate(data['nextDue'])),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVaccineRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Color(0xFF666666))),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1A237E))),
      ],
    );
  }

  String _formatDate(String date) {
    try {
      final dt = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return date;
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Search Records', style: TextStyle(fontWeight: FontWeight.w700)),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search by title, doctor, or description...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (value) {
            // Implement search
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            SizedBox(width: 12),
            Text('Export feature coming soon!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF0091EA),
      ),
    );
  }
}
